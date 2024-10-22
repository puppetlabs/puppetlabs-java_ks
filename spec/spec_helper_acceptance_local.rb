# frozen_string_literal: true

UNSUPPORTED_PLATFORMS = [].freeze
require 'singleton'

class LitmusHelper
  include Singleton
  include PuppetLitmus
end

def keytool_command(arguments)
  # The @keytool global does not exist right now as the function is defined.
  # When the tests call the function, RSpec.shared_context below will have run
  # by then and the variable will exist.
  # os[:family] == 'windows' ? interpolate_powershell("& '#{@keytool_path}keytool'") : "'#{@keytool_path}keytool'"
  if os[:family] == 'windows'
    interpolate_powershell("& '#{@keytool_path}keytool' #{arguments}")
  else
    "'#{@keytool_path}keytool' #{arguments}"
  end
end

def interpolate_powershell(command)
  "powershell.exe -NoProfile -Nologo -Command \"#{command}\""
end

def remote_windows_temp_dir
  @remote_windows_temp_dir ||= "#{LitmusHelper.instance.run_shell(interpolate_powershell('echo "$ENV:TEMP"')).stdout.strip.tr('\\', '/')}/"
  @remote_windows_temp_dir
end

def remote_file_exists?(filename)
  if os[:family] == 'windows'
    LitmusHelper.instance.run_shell(interpolate_powershell("Get-Item -Path '#{filename}' -ErrorAction SilentlyContinue"), expect_failures: true)
  else
    LitmusHelper.instance.run_shell("test -f '#{filename}'", expect_failures: true)
  end
end

def temp_dir
  @temp_dir ||= (os[:family] == 'windows') ? remote_windows_temp_dir : '/tmp/'
  @temp_dir
end

def create_and_upload_certs
  cert_files = ['privkey.pem', 'ca.pem', 'ca.der', 'ca2.pem', 'chain.pem', 'chain2.pem', 'leafkey.pem', 'leaf.pem', 'leafchain.pem', 'leafchain2.pem', 'leaf.p12', 'leaf2.p12']
  recreate_certs = false
  cert_files.each do |cert_file|
    recreate_certs = true unless File.file?("spec/acceptance/certs/#{cert_file}")
  end
  create_certs if recreate_certs
  cert_files.each do |cert_file|
    if ENV['TARGET_HOST'].nil? || ENV['TARGET_HOST'] == 'localhost'
      command = "cp spec\\acceptance\\certs\\#{cert_file} #{ENV.fetch('TEMP', nil)}\\#{cert_file}"
      command = interpolate_powershell(command) if os[:family] == 'windows'
      Open3.capture3(command)
    else
      LitmusHelper.instance.bolt_upload_file("spec/acceptance/certs/#{cert_file}", "#{temp_dir}#{cert_file}")
    end
  end
end

def create_certs
  require 'openssl'
  key = OpenSSL::PKey::RSA.new 2048
  ca = OpenSSL::X509::Certificate.new
  ca.serial = 1
  ca.public_key = key.public_key
  subj = '/CN=Test CA/ST=Denial/L=Springfield/O=Dis/CN=www.example.com'
  ca.subject = OpenSSL::X509::Name.parse subj
  ca.issuer = ca.subject
  ca.not_before = Time.now
  ca.not_after = ca.not_before + 360
  ca.sign(key, OpenSSL::Digest.new('SHA256'))

  key2 = OpenSSL::PKey::RSA.new 2048
  ca2 = OpenSSL::X509::Certificate.new
  ca2.serial = 2
  ca2.public_key = key2.public_key
  subj2 = '/CN=Test CA/ST=Denial/L=Springfield/O=Dis/CN=www.example.com'
  ca2.subject = OpenSSL::X509::Name.parse subj2
  ca2.issuer = ca2.subject
  ca2.not_before = Time.now
  ca2.not_after = ca2.not_before + 360
  ca2.sign(key2, OpenSSL::Digest.new('SHA256'))

  key_chain = OpenSSL::PKey::RSA.new 2048
  chain = OpenSSL::X509::Certificate.new
  chain.serial = 3
  chain.public_key = key_chain.public_key
  chain_subj = '/CN=Chain CA/ST=Denial/L=Springfield/O=Dis/CN=www.example.net'
  chain.subject = OpenSSL::X509::Name.parse chain_subj
  chain.issuer = ca.subject
  chain.not_before = Time.now
  chain.not_after = chain.not_before + 360
  chain.sign(key, OpenSSL::Digest.new('SHA256'))

  key_chain2 = OpenSSL::PKey::RSA.new 2048
  chain2 = OpenSSL::X509::Certificate.new
  chain2.serial = 4
  chain2.public_key = key_chain2.public_key
  chain2_subj = '/CN=Chain CA 2/ST=Denial/L=Springfield/O=Dis/CN=www.example.net'
  chain2.subject = OpenSSL::X509::Name.parse chain2_subj
  chain2.issuer = chain.subject
  chain2.not_before = Time.now
  chain2.not_after = chain2.not_before + 360
  chain2.sign(key_chain, OpenSSL::Digest.new('SHA256'))

  key_leaf = OpenSSL::PKey::RSA.new 2048
  leaf = OpenSSL::X509::Certificate.new
  leaf.serial = 5
  leaf.public_key = key_leaf.public_key
  leaf_subj = '/CN=Leaf Cert/ST=Denial/L=Springfield/O=Dis/CN=www.example.net'
  leaf.subject = OpenSSL::X509::Name.parse leaf_subj
  leaf.issuer = chain2.subject
  leaf.not_before = Time.now
  leaf.not_after = leaf.not_before + 360
  leaf.sign(key_chain2, OpenSSL::Digest.new('SHA256'))

  chain3 = OpenSSL::X509::Certificate.new
  chain3.serial = 6
  chain3.public_key = key_chain2.public_key
  chain3.subject = OpenSSL::X509::Name.parse chain2_subj
  chain3.issuer = ca.subject
  chain3.not_before = Time.now
  chain3.not_after = chain3.not_before + 360
  chain3.sign(key, OpenSSL::Digest.new('SHA256'))

  pkcs12 = OpenSSL::PKCS12.create('pkcs12pass', 'Leaf Cert', key_leaf, leaf, [chain2, chain])
  pkcs12_chain3 = OpenSSL::PKCS12.create('pkcs12pass', 'Leaf Cert', key_leaf, leaf, [chain3])

  create_cert_file('privkey.pem', key.to_pem)
  create_cert_file('ca.pem', ca.to_pem)
  create_cert_file('ca.der', ca.to_der)
  create_cert_file('ca2.pem', ca2.to_pem)
  create_cert_file('chain.pem', chain2.to_pem + chain.to_pem)
  create_cert_file('chain2.pem', chain3.to_pem)
  create_cert_file('leafkey.pem', key_leaf.to_pem)
  create_cert_file('leaf.pem', leaf.to_pem)
  create_cert_file('leafchain.pem', leaf.to_pem + chain2.to_pem + chain.to_pem)
  create_cert_file('leafchain2.pem', leaf.to_pem + chain3.to_pem)
  create_cert_file('leaf.p12', pkcs12.to_der)
  create_cert_file('leaf2.p12', pkcs12_chain3.to_der)
end

def create_cert_file(cert_name, contents)
  return if File.file?("spec/acceptance/certs/#{cert_name}")

  out_file = File.new("spec/acceptance/certs/#{cert_name}", 'w+')
  out_file.puts(contents)
  out_file.close
end

RSpec.configure do |c|
  c.before :suite do
    create_and_upload_certs
    # install java if windows
    if os[:family] == 'windows'
      LitmusHelper.instance.run_shell('puppet module install puppetlabs-chocolatey')
      pp_windows = <<~MANIFEST
        include chocolatey
        package { 'jre8':
          ensure   => '8.0.371',
          provider => 'chocolatey',
          install_options => ['-y']
        }
      MANIFEST
      LitmusHelper.instance.apply_manifest(pp_windows, catch_failures: true)
    else
      LitmusHelper.instance.run_shell('puppet module install puppetlabs-java')
      pp_linux = <<~MANIFEST
        class { 'java': }
      MANIFEST
      LitmusHelper.instance.apply_manifest(pp_linux)
    end
  end
end

RSpec.shared_context 'with common variables' do
  before(:each) do
    java_major, _java_minor = (ENV['JAVA_VERSION'] || '8u371').split('u')
    @ensure_ks = 'latest'
    @resource_path = 'undef'
    @target_dir = '/etc/'
    @temp_dir = temp_dir
    case os[:family]
    when 'solaris'
      @keytool_path = '/usr/java/bin/'
      @resource_path = "['/usr/java/bin/','/opt/puppet/bin/']"
    when 'aix'
      @keytool_path = '/usr/java6/bin/'
      @resource_path = "['/usr/java6/bin/','/usr/bin/']"
    when 'windows'
      @ensure_ks = 'present'
      @keytool_path = "C:/Program Files/Java/jre-1.#{java_major}/bin/"
      @resource_path = "['C:/Program Files/Java/jre-1.#{java_major}/bin/']"
    when 'ubuntu'
      @ensure_ks = 'present' if ['20.04', '22.04'].include?(os[:release])
    when 'debian'
      @ensure_ks = 'present' if os[:release].match?(%r{^11|12})
    end
  end
end
