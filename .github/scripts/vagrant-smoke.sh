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

echo "::group::Generate host config for ${platform}"
hosts=$(cd "$root" && bundle exec ruby bin/beaker-hostgenerator --hypervisor vagrant_libvirt "${platform}a")
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
  echo "::error::beaker-hostgenerator did not generate a box for ${platform}"
  exit 1
fi

export SMOKE_BOX=$box
export SMOKE_BOX_URL=${box_url:-}
export VAGRANT_DEFAULT_PROVIDER=libvirt

workdir=$(mktemp -d)

cleanup() {
  cd "$workdir" && vagrant destroy -f || true
  vagrant box remove "$SMOKE_BOX" --all --force || true
  cd / && rm -rf "$workdir"
}
trap cleanup EXIT

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
vagrant up --provider=libvirt
echo "::endgroup::"

echo "::group::Guest information"
vagrant ssh -c 'cat /etc/os-release'
actual_arch=$(vagrant ssh -c 'uname -m' 2>/dev/null | tr -d '\r' | tail -n 1)
echo "Guest architecture: ${actual_arch}"
echo "::endgroup::"

if [ "$actual_arch" != "$expected_arch" ]; then
  echo "::error::${platform} was expected to be ${expected_arch} but the box is ${actual_arch}"
  exit 1
fi

echo "${platform}: box ${SMOKE_BOX} booted"
