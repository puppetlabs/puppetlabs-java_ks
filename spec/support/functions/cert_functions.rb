def copy_certs_to_sut
  if os[:family] =~ %r{windows}i
    temp_dir = 'C:/tmp/'
    run_shell('mkdir c:\\tmp', {:expect_failures => true})
  else
    temp_dir = '/tmp/'
  end

  certs_dir = File.join(File.dirname(__FILE__), '../files')

  Dir.foreach(certs_dir) do |cert|
    next if File.directory? cert
    full_path = File.join(certs_dir,cert)
    bolt_upload_file(full_path,"#{temp_dir}#{cert}")
  end
end

# The code below is preserved to make it easier to discover the fact that the
# wheel need not be reinvented if a mainter of this module ever needs to
# regenerate a set of certificates as are currently found in the
# spec/support/files directory.

# The code below is what was formerly found in the
# spec/spec_helper_acceptance.rb file prior to the file's conversion to Litmus
# testing. This code was found to be problematic for reasons such as the fact
# that if the tests were run using a Windows machine as the test controller,
# then the OpenSSL Gem had bugs that would cause the certs to be generated
# incorrectly and tests would fail, not because the tests or the module were
# broken, but because the certs were invalid. For that reason the decision was
# made to generate the certificates one time with a 20yr expiration from a Linux
# machine where the OpenSSL gem works, include the certs in spec/support/files,
# and stop generating them on the fly with each test run.

# However, if the need should ever arrise for the certs to be regenerated, you
# can uncomment the code below, call the create_keys_for_test function from the
# code block in c.before :suite, and the certs will regenerate. Keep in mind
# however the the code at the bottom of the create_certs function that copies
# the certificates to the end machine is incorrect. That code is pre-litmus
# methodology that relies on beaker test helpers that no longer exist in this
# module's dependencies. If you need to regenerate certs you will need to adapt
# that code to create a temporary file and use something such as the
# bolt_upload_file function above to copy to the remote hosts, or simply
# generate the files locally, and replace the existing files in the
# spec/support/files directory.

# def create_keys_for_test(host)
#   # Generate private key and CA for keystore
#   if host['platform'] =~ %r{windows}i
#     temp_dir = 'C:\\tmp\\'
#     on host, 'mkdir /cygdrive/c/tmp'
#   else
#     temp_dir = '/tmp/'
#   end

#   create_certs(host, temp_dir)
# end

# def create_certs(host, tmpdir)
#   require 'openssl'
#   key = OpenSSL::PKey::RSA.new 1024
#   ca = OpenSSL::X509::Certificate.new
#   ca.serial = 1
#   ca.public_key = key.public_key
#   subj = '/CN=Test CA/ST=Denial/L=Springfield/O=Dis/CN=www.example.com'
#   ca.subject = OpenSSL::X509::Name.parse subj
#   ca.issuer = ca.subject
#   ca.not_before = Time.now
#   ca.not_after = ca.not_before + 360
#   ca.sign(key, OpenSSL::Digest::SHA256.new)

#   key2 = OpenSSL::PKey::RSA.new 1024
#   ca2 = OpenSSL::X509::Certificate.new
#   ca2.serial = 2
#   ca2.public_key = key2.public_key
#   subj2 = '/CN=Test CA/ST=Denial/L=Springfield/O=Dis/CN=www.example.com'
#   ca2.subject = OpenSSL::X509::Name.parse subj2
#   ca2.issuer = ca2.subject
#   ca2.not_before = Time.now
#   ca2.not_after = ca2.not_before + 360
#   ca2.sign(key2, OpenSSL::Digest::SHA256.new)

#   key_chain = OpenSSL::PKey::RSA.new 1024
#   chain = OpenSSL::X509::Certificate.new
#   chain.serial = 3
#   chain.public_key = key_chain.public_key
#   chain_subj = '/CN=Chain CA/ST=Denial/L=Springfield/O=Dis/CN=www.example.net'
#   chain.subject = OpenSSL::X509::Name.parse chain_subj
#   chain.issuer = ca.subject
#   chain.not_before = Time.now
#   chain.not_after = chain.not_before + 360
#   chain.sign(key, OpenSSL::Digest::SHA256.new)

#   key_chain2 = OpenSSL::PKey::RSA.new 1024
#   chain2 = OpenSSL::X509::Certificate.new
#   chain2.serial = 4
#   chain2.public_key = key_chain2.public_key
#   chain2_subj = '/CN=Chain CA 2/ST=Denial/L=Springfield/O=Dis/CN=www.example.net'
#   chain2.subject = OpenSSL::X509::Name.parse chain2_subj
#   chain2.issuer = chain.subject
#   chain2.not_before = Time.now
#   chain2.not_after = chain2.not_before + 360
#   chain2.sign(key_chain, OpenSSL::Digest::SHA256.new)

#   key_leaf = OpenSSL::PKey::RSA.new 1024
#   leaf = OpenSSL::X509::Certificate.new
#   leaf.serial = 5
#   leaf.public_key = key_leaf.public_key
#   leaf_subj = '/CN=Leaf Cert/ST=Denial/L=Springfield/O=Dis/CN=www.example.net'
#   leaf.subject = OpenSSL::X509::Name.parse leaf_subj
#   leaf.issuer = chain2.subject
#   leaf.not_before = Time.now
#   leaf.not_after = leaf.not_before + 360
#   leaf.sign(key_chain2, OpenSSL::Digest::SHA256.new)

#   chain3 = OpenSSL::X509::Certificate.new
#   chain3.serial = 6
#   chain3.public_key = key_chain2.public_key
#   chain3.subject = OpenSSL::X509::Name.parse chain2_subj
#   chain3.issuer = ca.subject
#   chain3.not_before = Time.now
#   chain3.not_after = chain3.not_before + 360
#   chain3.sign(key, OpenSSL::Digest::SHA256.new)

#   pkcs12 = OpenSSL::PKCS12.create('pkcs12pass', 'Leaf Cert', key_leaf, leaf, [chain2, chain])
#   pkcs12_chain3 = OpenSSL::PKCS12.create('pkcs12pass', 'Leaf Cert', key_leaf, leaf, [chain3])

#   create_remote_file(host, "#{tmpdir}/privkey.pem", key.to_pem)
#   create_remote_file(host, "#{tmpdir}/ca.pem", ca.to_pem)
#   create_remote_file(host, "#{tmpdir}/ca2.pem", ca2.to_pem)
#   create_remote_file(host, "#{tmpdir}/chain.pem", chain2.to_pem + chain.to_pem)
#   create_remote_file(host, "#{tmpdir}/chain2.pem", chain3.to_pem)
#   create_remote_file(host, "#{tmpdir}/leafkey.pem", key_leaf.to_pem)
#   create_remote_file(host, "#{tmpdir}/leaf.pem", leaf.to_pem)
#   create_remote_file(host, "#{tmpdir}/leafchain.pem", leaf.to_pem + chain2.to_pem + chain.to_pem)
#   create_remote_file(host, "#{tmpdir}/leafchain2.pem", leaf.to_pem + chain3.to_pem)
#   create_remote_file(host, "#{tmpdir}/leaf.p12", pkcs12.to_der)
#   create_remote_file(host, "#{tmpdir}/leaf2.p12", pkcs12_chain3.to_der)
# end