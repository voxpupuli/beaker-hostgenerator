# Executed by Beaker on the Linux runner against a real OpenBSD VM.
require 'digest'
require 'securerandom'
require 'tmpdir'

test_name 'OpenBSD SSH file transfer' do
  host = hosts.first

  step 'SCP a file to OpenBSD and retrieve it without modification' do
    Dir.mktmpdir('beaker-openbsd-') do |local_directory|
      payload = "OpenBSD via Beaker \n#{SecureRandom.hex(32)}\n"
      source = File.join(local_directory, 'source.txt')
      download_directory = File.join(local_directory, 'download')
      destination = File.join(download_directory, 'source.txt')
      File.binwrite(source, payload)
      Dir.mkdir(download_directory)
      remote_directory = "/tmp/beaker-openbsd-#{SecureRandom.hex(12)}"
      remote_file = "#{remote_directory}/source.txt"

      begin
        on(host, "mkdir #{remote_directory}")
        scp_to(host, source, remote_file)
        on(host, "test -f #{remote_file} && test -s #{remote_file}")
        # Beaker defaults to recursive downloads; use a known directory
        # and disable recursion when transferring one regular file.
        scp_from(host, remote_file, download_directory, recursive: false)
        raise "SCP download did not create #{destination}" unless File.file?(destination)

        source_digest = Digest::SHA256.file(source).digest
        returned_digest = Digest::SHA256.file(destination).digest
        raise 'SCP changed the file contents' unless source_digest == returned_digest
      ensure
        on(host, "rm -rf #{remote_directory}")
      end
    end
  end
end
