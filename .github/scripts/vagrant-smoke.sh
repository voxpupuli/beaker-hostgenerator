#!/usr/bin/env bash
#
# Boot the Vagrant box that beaker-hostgenerator generates for a platform and
# check that it comes up under libvirt, answers over SSH, resolves names and can
# refresh its package metadata.
#
# The regular test suite only compares generated host configs with fixtures,
# so it cannot notice a box that was removed, moved or no longer boots.
#
# Usage: .github/scripts/vagrant-smoke.sh <platform>
#   e.g. .github/scripts/vagrant-smoke.sh rocky10-64
#
# Needs Vagrant with the vagrant-libvirt plugin, a working libvirt and the
# gems from the Gemfile (bundle install).
#
# The box is left in the local Vagrant cache afterwards, because a box with
# the same name may have been there before the test. Set SMOKE_REMOVE_BOX=1
# to remove it (all its libvirt versions) when the test is done.

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
    if [ -n "${SMOKE_BOX:-}" ] && [ "${SMOKE_REMOVE_BOX:-}" = 1 ]; then
      vagrant box remove "$SMOKE_BOX" --provider libvirt --all || true
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

# True when the failed `vagrant up` in $1 was a download problem that is not an
# HTTP client error: a 5xx from the registry, a dropped connection, a timeout.
# Those come and go, and reporting them would make a healthy box look broken.
# A 404 means the box is gone, and a box that downloads but does not boot is a
# real result as well. Neither is retried (a slow boot also prints "Connection
# reset" while Vagrant waits for SSH, so connection errors alone say nothing).
is_transient() {
  grep -qE 'error occurred while downloading|remote catalog' "$1" &&
    ! grep -qE 'returned error: 4[0-9][0-9]' "$1"
}

attempts=3
up_ok=''
echo "::group::vagrant up ${platform} (box=${SMOKE_BOX} box_url=${SMOKE_BOX_URL:-none})"
for attempt in $(seq 1 "$attempts"); do
  if vagrant up --provider=libvirt 2>&1 | tee up.log; then
    up_ok=1
    break
  fi
  if [ "$attempt" -lt "$attempts" ] && is_transient up.log; then
    echo "::warning title=${platform}: vagrant up hit a download error::attempt ${attempt} of ${attempts} failed, trying again"
    vagrant destroy -f || true
    sleep "${SMOKE_RETRY_DELAY:-30}"
    continue
  fi
  break
done
echo "::endgroup::"
if [ -z "$up_ok" ]; then
  fail "vagrant up failed" "box ${SMOKE_BOX}${SMOKE_BOX_URL:+ from ${SMOKE_BOX_URL}}"$'\n'"$(error_tail up.log)"
fi

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

# The guest has to be the OS and release the platform names, not just boot.
# VERSION_ID matches exactly or with more components (10 matches 10.1, but
# 24.04 does not match 24.10). os-release IDs that differ from the platform
# name are mapped here.
os_id=$(sed -n 's/^ID=//p' os-release | tr -d '"\r')
os_version=$(sed -n 's/^VERSION_ID=//p' os-release | tr -d '"\r')
platform_os=${platform%%-*}
expected_version=$(sed -E 's/^[a-z]+//' <<<"$platform_os")
case "$platform_os" in
  ubuntu*)
    expected_id=ubuntu
    expected_version="${expected_version:0:2}.${expected_version:2}"
    ;;
  oracle*) expected_id=ol ;;
  amazon*) expected_id=amzn ;;
  *) expected_id=$(sed -E 's/[0-9].*//' <<<"$platform_os") ;;
esac
if [ "$os_id" != "$expected_id" ] ||
  { [ "$os_version" != "$expected_version" ] && [ "${os_version#"$expected_version".}" = "$os_version" ]; }; then
  fail "Wrong guest OS" "expected ${expected_id} ${expected_version}, the box is ${os_id:-unknown} ${os_version:-unknown}"
fi

# A guest that boots is not necessarily usable: a broken resolver or stale
# package repositories only show up when someone tries to install something.
# Check that the guest can resolve names, then that its package manager can
# refresh its metadata.
echo "::group::Guest network and package manager"
if ! vagrant ssh -c 'getent hosts github.com' > dns.log 2>&1; then
  cat dns.log
  echo "::endgroup::"
  fail "DNS resolution failed in the guest" "getent hosts github.com failed"$'\n'"$(error_tail dns.log)"
fi
cat dns.log

# apt-get update exits 0 when it could not fetch some indexes, so the output is
# checked as well. dnf makecache --refresh exits non-zero on its own. The
# command runs in the guest, so its variables must not expand here.
# shellcheck disable=SC2016
apt_refresh='
out=$(sudo apt-get -q update 2>&1)
status=$?
echo "$out"
[ "$status" -eq 0 ] && ! echo "$out" | grep -qE "^(E:|W: Failed to fetch)"
'
dnf_refresh='sudo dnf -q -y makecache --refresh'

case "$platform_os" in
  debian* | ubuntu*) refresh=$apt_refresh ;;
  *) refresh=$dnf_refresh ;;
esac

if ! vagrant ssh -c "$refresh" > refresh.log 2>&1; then
  cat refresh.log
  echo "::endgroup::"
  fail "Package metadata refresh failed" "$(error_tail refresh.log)"
fi
cat refresh.log
echo "::endgroup::"

os_name=$(grep -m 1 '^PRETTY_NAME=' os-release | cut -d= -f2- | tr -d '"\r') || true
summary "✅ **${platform}** (\`${SMOKE_BOX}\`): booted ${os_name:-unknown OS}, ${actual_arch}"
echo "${platform}: box ${SMOKE_BOX} booted"
