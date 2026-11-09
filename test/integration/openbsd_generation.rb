# Verify OpenBSD generator mappings, OSINFO compatibility, and a mixed layout.
# Run on the Linux GitHub Actions runner with this PR's bundled executable.
require 'open3'
require 'yaml'

release = ENV.fetch('OPENBSD_RELEASE')
short_release = release.delete('.')
platform = "openbsd-#{release}-amd64"
host_name = "openbsd#{short_release}-64-1"

overrides = {
  'vmpooler'       => %W[template openbsd-#{release}-amd64],
  'abs'            => %W[template openbsd-#{release}-amd64],
  'vagrant'        => %w[box custom/openbsd],
  'vagrant_libvirt' => %w[box custom/openbsd],
  'docker'         => %w[image example/openbsd:custom],
  'none'           => %w[user test-user],
}

backends = {
  'vmpooler'       => {},
  'abs'            => {},
  'vagrant'        => { 'box' => "generic/openbsd#{short_release}", 'synced_folder' => 'disabled' },
  'vagrant_libvirt' => { 'box' => "generic/openbsd#{short_release}", 'synced_folder' => 'disabled' },
  'docker'         => { 'image' => "amd64/openbsd:#{short_release}", 'docker_cmd' => ['/sbin/init'] },
  'none'           => {},
}

def generate(*arguments)
  output, errors, status = Open3.capture3('bundle', 'exec', 'beaker-hostgenerator', *arguments)
  raise "Generator failed for #{arguments.inspect}: #{errors}" unless status.success?

  YAML.safe_load(output)
end

(0..1).each do |osinfo|
  # The public --list interface must advertise the exact new host keys.
  list_args = ['bundle', 'exec', 'beaker-hostgenerator', '--osinfo-version', osinfo.to_s, '--list']
  output, errors, status = Open3.capture3(*list_args)
  raise "Cannot enumerate OSINFO #{osinfo}: #{errors}" unless status.success?

  listed = output.lines.any? { |line| line.strip == "openbsd#{short_release}-64" }
  raise "OpenBSD #{release} missing from --list (OSINFO #{osinfo})" unless listed

  backends.each do |backend, expected_fields|
    config_args = ['--osinfo-version', osinfo.to_s, '--hypervisor', backend, "openbsd#{short_release}-64a"]
    config = generate(*config_args)
    hosts = config.fetch('HOSTS')
    raise "Unexpected #{backend} host names: #{hosts.keys.inspect}" unless hosts.keys == [host_name]

    host = hosts.fetch(host_name)
    raise "Wrong platform (#{backend}): #{host['platform']}" unless host['platform'] == platform

    raise "Wrong hypervisor (#{backend}): #{host['hypervisor']}" unless host['hypervisor'] == backend

    raise "Missing agent role (#{backend})" unless host.fetch('roles') == %w[agent]

    expected_fields.each do |key, value|
      raise "Wrong #{backend} #{key}: #{host[key].inspect}" unless host[key] == value
    end
    if backend == 'vmpooler'
      api = config.fetch('CONFIG').fetch('pooling_api')
      raise "Unexpected VMPooler endpoint: #{api}" unless api.start_with?('https://')
    else
      raise "Unexpected global CONFIG (#{backend})" unless config.fetch('CONFIG') == {}
    end
    # User-provided, verified image/pool identifiers must override guesses.
    override_key, override_value = overrides.fetch(backend)
    override_spec = "openbsd#{short_release}-64a{#{override_key}=#{override_value}}"
    override_args = ['--osinfo-version', osinfo.to_s, '--hypervisor', backend, override_spec]
    configured = generate(*override_args)
    override_host = configured.fetch('HOSTS').fetch(host_name)
    raise "#{backend} override lost" unless override_host.fetch(override_key) == override_value

    raise "#{backend} override changed platform" unless override_host.fetch('platform') == platform

    puts "#{release} OSINFO #{osinfo} #{backend}: default and override OK"
  end
end

# Tokenization must not mistake the dots in either real Beaker platform name
# for separators or lose an OpenBSD host in a multiple-host layout.
mixed = generate('openbsd79-64a-openbsd80-64a')
%w[7.9 8.0].each do |version|
  key = "openbsd#{version.delete('.')}-64-1"
  actual_platform = mixed.fetch('HOSTS').fetch(key).fetch('platform')
  raise "Missing mixed-layout host: #{key}" unless actual_platform == "openbsd-#{version}-amd64"
end
raise 'Extra mixed-layout hosts' unless mixed.fetch('HOSTS').size == 2

puts 'Mixed OpenBSD 7.9/8.0 layout: OK'

# The native QEMU image uses SSH forwarding on the host. It is a static host:
# it must not accidentally be provisioned again through VMPooler or Vagrant.
static_config = generate('--hypervisor', 'none', "openbsd#{short_release}-64a")
host = static_config.fetch('HOSTS').fetch(host_name)
host['ip'] = '127.0.0.1'
host['user'] = 'root'
host['ssh'] = {
  'user'         => 'root',
  'port'         => 20_022,
  'keys'         => [File.join(Dir.home, '.ssh/id_rsa')],
  'auth_methods' => %w[publickey],
}
File.write(ENV.fetch('BEAKER_HOSTS_FILE'), YAML.dump(static_config))
