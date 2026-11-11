# Executed by Beaker on the Linux runner against a live QEMU OpenBSD guest.
test_name 'OpenBSD QEMU integration' do
  host = hosts.first
  expected_release = ENV.fetch('OPENBSD_RELEASE')
  expected_platform = "openbsd-#{expected_release}-amd64"

  step 'Validate the generated Beaker platform' do
    raise "Wrong Beaker platform: #{host['platform']}" unless host['platform'] == expected_platform
  end

  step 'Execute OpenBSD commands over SSH' do
    {
      'uname -s' => 'OpenBSD',
      'uname -r' => expected_release,
      'uname -m' => 'amd64',
    }.each do |command, expected|
      actual = on(host, command).stdout.strip
      raise "#{command}: expected #{expected}, got #{actual}" unless actual == expected
    end
  end

  step 'Verify OpenBSD package tools are reachable through Beaker' do
    on(host, 'command -v pkg_info')
  end
end
