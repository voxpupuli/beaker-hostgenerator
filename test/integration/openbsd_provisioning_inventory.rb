# Best-effort public artifact discovery; not a VM provisioning test.
# Never treats a network failure or missing box as a passing VM boot.
require 'json'
require 'net/http'
require 'open3'
require 'uri'

release = ENV.fetch('OPENBSD_RELEASE')
short_release = release.delete('.')
box = "generic/openbsd#{short_release}"
summary = ENV.fetch('GITHUB_STEP_SUMMARY', nil)
rows = []

begin
  uri = URI("https://app.vagrantup.com/api/v2/vagrant/#{box}")
  response = Net::HTTP.start(uri.host, uri.port, use_ssl: true,
                                                 open_timeout: 8, read_timeout: 8) { |http| http.get(uri.request_uri) }
  if response.is_a?(Net::HTTPSuccess)
    info = JSON.parse(response.body)
    providers = Array(info['versions']).flat_map { |version| Array(version['providers']) }
    provider_names = providers.map { |provider| provider['name'] }.uniq
    %w[virtualbox libvirt].each do |provider|
      status = if provider_names.include?(provider)
                 'Listed (boot unverified)'
               else
                 'Not listed (boot unverified)'
               end
      rows << ["Vagrant #{provider}", status]
    end
  elsif response.code == '404'
    %w[virtualbox libvirt].each { |provider| rows << ["Vagrant #{provider}", 'No public box found'] }
  else
    %w[virtualbox libvirt].each do |provider|
      rows << ["Vagrant #{provider}", "Catalog HTTP #{response.code}; unverified"]
    end
  end
rescue StandardError => e
  %w[virtualbox libvirt].each { |provider| rows << ["Vagrant #{provider}", "Catalog unavailable (#{e.class})"] }
end

# Docker on a Linux runner cannot run an OpenBSD kernel. Checking the registry
# may still reveal whether the default generated image name resolves at all.
image = "amd64/openbsd:#{short_release}"
if system('command -v docker >/dev/null 2>&1')
  _out, _err, process = Open3.capture3('timeout', '20', 'docker', 'manifest', 'inspect', image)
  result = if process.success?
             'Found; cannot boot OpenBSD on Linux'
           else
             'Not resolved; cannot boot OpenBSD on Linux'
           end
  rows << ['Docker image manifest', result]
else
  rows << ['Docker image manifest', 'Docker CLI absent; not checked']
end
rows << ['VMPooler', 'No known OpenBSD pool or credentials; provisioning not attempted']
rows << ['ABS', 'No known OpenBSD scheduler or credentials; provisioning not attempted']

puts "OpenBSD #{release} external provisioning inventory:"
rows.each { |backend, status| puts "  #{backend}: #{status}" }
if summary && !summary.empty?
  File.open(summary, 'a') do |f|
    f.puts "### OpenBSD #{release} external provisioning inventory"
    f.puts '| Backend | Result |'
    f.puts '| --- | --- |'
    rows.each { |backend, status| f.puts "| #{backend} | #{status} |" }
    f.puts
    f.puts 'These are artifact-availability checks only; none establishes working provisioned guests.'
  end
end
