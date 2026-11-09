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
      destination = File.join(local_directory, 'returned.txt')
      File.binwrite(source, payload)
      remote_directory = "/tmp/beaker-openbsd-#{SecureRandom.hex(12)}"

      begin
        on(host, "mkdir #{remote_directory}")
        scp_to(host, source, "#{remote_directory}/source.txt")
        scp_from(host, "#{remote_directory}/source.txt", destination)
        raise 'SCP destination does not exist' unless File.file?(destination)

        source_digest = Digest::SHA256.file(source).digest
        returned_digest = Digest::SHA256.file(destination).digest
        raise 'SCP changed the file contents' unless source_digest == returned_digest
      ensure
        on(host, "rm -rf #{remote_directory}")
      end
    end
  end
end
