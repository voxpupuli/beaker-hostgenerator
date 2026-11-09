# For manually triggered provisioning on a prepared, trusted CI runner.
# The runner must supply provider plugins and access to trusted images/pools.
require 'open3'
require 'yaml'

backend = ENV.fetch('PROVISION_BACKEND')
release = ENV.fetch('OPENBSD_RELEASE')
raise "Invalid release #{release}" unless %w[7.9 8.0].include?(release)
raise "Invalid backend #{backend}" unless %w[vagrant_libvirt vmpooler abs].include?(backend)
short = release.delete('.')
image = if backend == 'vagrant_libvirt'
          ENV.fetch("VAGRANT_BOX_#{short}", '').strip
        else
          ENV.fetch("TEMPLATE_#{short}", '').strip
        end
raise "No #{backend} image/pool supplied for #{release}" if image.empty?
raise 'Invalid image/pool identifier' if image.match?(/[{},\r\n]/)

setting_name = backend == 'vagrant_libvirt' ? 'box' : 'template'
spec = "openbsd#{short}-64a{#{setting_name}=#{image}}"
output, stderr, status = Open3.capture3('bundle', 'exec', 'beaker-hostgenerator',
                                        '--hypervisor', backend, spec)
raise "Generator failed: #{stderr}" unless status.success?

config = YAML.safe_load(output)
host = config.fetch('HOSTS').fetch("openbsd#{short}-64-1")
raise 'Wrong platform' unless host['platform'] == "openbsd-#{release}-amd64"
raise 'Wrong hypervisor' unless host['hypervisor'] == backend
raise 'Wrong image/pool' unless host[setting_name] == image
File.write(ENV.fetch('BEAKER_HOSTS_FILE'), YAML.dump(config))

# Export resolved box for the subsequent `vagrant box add` step.
if backend == 'vagrant_libvirt'
  File.open(ENV.fetch('GITHUB_ENV'), 'a') do |file|
    file.puts("PROVISION_IMAGE=#{image}")
  end
end
puts "Generated #{backend} configuration for OpenBSD #{release}"
