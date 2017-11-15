require 'beaker-rspec/spec_helper'
require 'beaker-rspec/helpers/serverspec'
require 'beaker/puppet_install_helper'

run_puppet_install_helper
install_ca_certs_on default if default['platform'] =~ /windows/i

UNSUPPORTED_PLATFORMS = []

def create_keys_for_test(host)
  # Generate private key and CA for keystore
  if host['platform'] =~ /windows/i
    temp_dir = 'C:\\tmp\\'
    on host, 'mkdir /cygdrive/c/tmp'
  else
    temp_dir = '/tmp/'
  end

  create_certs(host, temp_dir)
end

def create_certs(host, tmpdir)
  require 'openssl'
  key = OpenSSL::PKey::RSA.new 1024
  ca = OpenSSL::X509::Certificate.new
  ca.serial = 1
  ca.public_key = key.public_key
  subj = '/CN=Test CA/ST=Denial/L=Springfield/O=Dis/CN=www.example.com'
  ca.subject = OpenSSL::X509::Name.parse subj
  ca.issuer = ca.subject
  ca.not_before = Time.now
  ca.not_after = ca.not_before + 360
  ca.sign(key, OpenSSL::Digest::SHA256.new)

  key2 = OpenSSL::PKey::RSA.new 1024
  ca2 = OpenSSL::X509::Certificate.new
  ca2.serial = 2
  ca2.public_key = key2.public_key
  subj2 = '/CN=Test CA/ST=Denial/L=Springfield/O=Dis/CN=www.example.com'
  ca2.subject = OpenSSL::X509::Name.parse subj2
  ca2.issuer = ca2.subject
  ca2.not_before = Time.now
  ca2.not_after = ca2.not_before + 360
  ca2.sign(key2, OpenSSL::Digest::SHA256.new)

  key_chain = OpenSSL::PKey::RSA.new 1024
  chain = OpenSSL::X509::Certificate.new
  chain.serial = 3
  chain.public_key = key_chain.public_key
  chain_subj = '/CN=Chain CA/ST=Denial/L=Springfield/O=Dis/CN=www.example.net'
  chain.subject = OpenSSL::X509::Name.parse chain_subj
  chain.issuer = ca.subject
  chain.not_before = Time.now
  chain.not_after = chain.not_before + 360
  chain.sign(key, OpenSSL::Digest::SHA256.new)

  key_chain2 = OpenSSL::PKey::RSA.new 1024
  chain2 = OpenSSL::X509::Certificate.new
  chain2.serial = 4
  chain2.public_key = key_chain2.public_key
  chain2_subj = '/CN=Chain CA 2/ST=Denial/L=Springfield/O=Dis/CN=www.example.net'
  chain2.subject = OpenSSL::X509::Name.parse chain2_subj
  chain2.issuer = chain.subject
  chain2.not_before = Time.now
  chain2.not_after = chain2.not_before + 360
  chain2.sign(key_chain, OpenSSL::Digest::SHA256.new)

  key_leaf = OpenSSL::PKey::RSA.new 1024
  leaf = OpenSSL::X509::Certificate.new
  leaf.serial = 5
  leaf.public_key = key_leaf.public_key
  leaf_subj = '/CN=Leaf Cert/ST=Denial/L=Springfield/O=Dis/CN=www.example.net'
  leaf.subject = OpenSSL::X509::Name.parse leaf_subj
  leaf.issuer = chain2.subject
  leaf.not_before = Time.now
  leaf.not_after = leaf.not_before + 360
  leaf.sign(key_chain2, OpenSSL::Digest::SHA256.new)

  pkcs12 = OpenSSL::PKCS12.create("pkcs12pass", "Leaf Cert", key_leaf, leaf, [chain2, chain])

  create_remote_file(host, "#{tmpdir}/privkey.pem", key.to_pem)
  create_remote_file(host, "#{tmpdir}/ca.pem", ca.to_pem)
  create_remote_file(host, "#{tmpdir}/ca2.pem", ca2.to_pem)
  create_remote_file(host, "#{tmpdir}/chain.pem", chain2.to_pem + chain.to_pem)
  create_remote_file(host, "#{tmpdir}/leafkey.pem", key_leaf.to_pem)
  create_remote_file(host, "#{tmpdir}/leaf.pem", leaf.to_pem)
  create_remote_file(host, "#{tmpdir}/leafchain.pem", leaf.to_pem + chain2.to_pem + chain.to_pem)
  create_remote_file(host, "#{tmpdir}/leaf.p12", pkcs12.to_der)
end


RSpec.configure do |c|
  # Project root
  proj_root = File.expand_path(File.join(File.dirname(__FILE__), '..'))

  # Readable test descriptions
  c.formatter = :documentation

  # Configure all nodes in nodeset
  c.before :suite do
    # Install module and dependencies
    hosts.each do |host|
      create_keys_for_test(host)
      copy_module_to(host, :source => proj_root, :module_name => 'java_ks')
      #install java if windows
      if host['platform'] =~ /windows/i
        on host, puppet('module install puppetlabs-chocolatey')
    pp = <<-EOS
include chocolatey
package { 'jdk8':
  ensure   => '8.0.152',
  provider => 'chocolatey'
}
    EOS
        apply_manifest_on(host, pp)
      else
        on host, puppet('module', 'install', 'puppetlabs-java'), {:acceptable_exit_codes => [0, 1]}
    pp = <<-EOS
class { 'java': }
    EOS
        apply_manifest_on(host, pp)
      end
    end
  end
end

RSpec.shared_context 'common variables' do
  before {
    java_major, java_minor = (ENV['JAVA_VERSION'] || '8u152').split('u')
    @ensure_ks = 'latest'
    @resource_path = "undef"
    @target_dir = '/etc/'
    @temp_dir = '/tmp/'
    case fact('osfamily')
      when "Solaris"
        @keytool_path = '/usr/java/bin/'
        @resource_path = "['/usr/java/bin/','/opt/puppet/bin/']"
      when "AIX"
        @keytool_path = '/usr/java6/bin/'
        @resource_path = "['/usr/java6/bin/','/usr/bin/']"
      when 'windows'
        @ensure_ks = 'present'
        @keytool_path = "C:/Program Files/Java/jdk1.#{java_major}.0_#{java_minor}/bin/"
        @resource_path = "['C:/Program\ Files/Java/jdk1.#{java_major}.0_#{java_minor}/bin/']"
        @target_dir = 'c:/'
        @temp_dir = 'C:/tmp/'
    end
  }
end
