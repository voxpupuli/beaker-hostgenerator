#!/usr/bin/env bash
#
# Boot the Vagrant box that beaker-hostgenerator generates for a platform and
# check that it comes up under libvirt and answers over SSH.
#
# The regular test suite only compares generated host configs with fixtures,
# so it cannot notice a box that was removed, moved or no longer boots.
#
# Usage: .github/scripts/vagrant-smoke.sh <platform>
#   e.g. .github/scripts/vagrant-smoke.sh rocky10-64
#
# Needs Vagrant with the vagrant-libvirt plugin, a working libvirt and the
# gems from the Gemfile (bundle install).

set -euo pipefail

platform=${1:?usage: $0 <platform>, e.g. rocky10-64}

root=$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)

case "$platform" in
  *-64) expected_arch=x86_64 ;;
  *-AARCH64) expected_arch=aarch64 ;;
  *)
    echo "Unsupported architecture in '$platform'; use <os>-64 or <os>-AARCH64" >&2
    exit 2
    ;;
esac

# Report a failure as a GitHub Actions annotation and in the job summary.
# Annotations are shown on the run page to everyone, while the job log needs
# a sign-in, so the reason has to be in the annotation to be useful.
fail() {
  local title=$1 message=$2
  if [ -n "${GITHUB_ACTIONS:-}" ]; then
    message=${message//'%'/'%25'}
    message=${message//$'\r'/'%0D'}
    message=${message//$'\n'/'%0A'}
    echo "::error title=${title}::${message}"
  else
    printf '%s\n%s\n' "$title" "$message" >&2
  fi
  summary "❌ **${platform}** (\`${SMOKE_BOX:-no box}\`): ${title}"
  exit 1
}

summary() {
  if [ -n "${GITHUB_STEP_SUMMARY:-}" ]; then
    echo "$1" >> "$GITHUB_STEP_SUMMARY"
  fi
}

# The last lines of a command's output, which is where Vagrant prints its
# error message. Blank lines, download progress and the fog warning that
# vagrant-libvirt prints on every run are left out.
error_tail() {
  tr '\r' '\n' < "$1" |
    grep -v -e '^[[:space:]]*$' -e 'Progress: ' -e '^\[fog\]\[WARNING\]' |
    tail -n 15 || true
}

workdir=$(mktemp -d)

cleanup() {
  if [ -f "$workdir/Vagrantfile" ]; then
    (cd "$workdir" && vagrant destroy -f) || true
    if [ -n "${SMOKE_BOX:-}" ]; then
      vagrant box remove "$SMOKE_BOX" --all --force || true
    fi
  fi
  rm -rf "$workdir"
}
trap cleanup EXIT

echo "::group::Generate host config for ${platform}"
if ! hosts=$(cd "$root" && bundle exec ruby bin/beaker-hostgenerator --hypervisor vagrant_libvirt "${platform}a" 2>"$workdir/generate.err"); then
  cat "$workdir/generate.err" >&2
  echo "::endgroup::"
  fail "beaker-hostgenerator failed" "$(error_tail "$workdir/generate.err")"
fi
echo "$hosts"
echo "::endgroup::"

# Print "<box> <box_url>" (the URL is empty when the box has none). read
# fails on empty input, which would end the script under set -e before the
# check below can report it.
box='' box_url=''
read -r box box_url < <(ruby -ryaml -e '
  host = YAML.safe_load(ARGF.read).fetch("HOSTS").values.first
  puts [host.fetch("box"), host["box_url"]].join(" ")
' <<<"$hosts") || true

if [ -z "${box:-}" ]; then
  fail "No box in the generated host config" "$hosts"
fi

export SMOKE_BOX=$box
export SMOKE_BOX_URL=${box_url:-}
export VAGRANT_DEFAULT_PROVIDER=libvirt

cd "$workdir"

# Same box settings that Beaker writes into its Vagrantfile, nothing else.
cat > Vagrantfile <<'EOF'
Vagrant.configure('2') do |config|
  config.vm.box = ENV.fetch('SMOKE_BOX')
  box_url = ENV.fetch('SMOKE_BOX_URL', '')
  config.vm.box_url = box_url unless box_url.empty?
  config.vm.synced_folder '.', '/vagrant', disabled: true
  config.vm.boot_timeout = 600
  config.vm.provider :libvirt do |libvirt|
    libvirt.cpus = 2
    libvirt.memory = 2048
  end
end
EOF

echo "::group::vagrant up ${platform} (box=${SMOKE_BOX} box_url=${SMOKE_BOX_URL:-none})"
if ! vagrant up --provider=libvirt 2>&1 | tee up.log; then
  echo "::endgroup::"
  fail "vagrant up failed" "box ${SMOKE_BOX}${SMOKE_BOX_URL:+ from ${SMOKE_BOX_URL}}"$'\n'"$(error_tail up.log)"
fi
echo "::endgroup::"

echo "::group::Guest information"
if ! vagrant ssh -c 'cat /etc/os-release' > os-release 2>&1; then
  cat os-release
  echo "::endgroup::"
  fail "SSH into the guest failed" "$(error_tail os-release)"
fi
cat os-release
actual_arch=$(vagrant ssh -c 'uname -m' 2>/dev/null | tr -d '\r' | tail -n 1) || true
echo "Guest architecture: ${actual_arch}"
echo "::endgroup::"

if [ "$actual_arch" != "$expected_arch" ]; then
  fail "Wrong guest architecture" "expected ${expected_arch}, the box is ${actual_arch:-unknown}"
fi

os_name=$(grep -m 1 '^PRETTY_NAME=' os-release | cut -d= -f2- | tr -d '"\r') || true
summary "✅ **${platform}** (\`${SMOKE_BOX}\`): booted ${os_name:-unknown OS}, ${actual_arch}"
echo "${platform}: box ${SMOKE_BOX} booted"
