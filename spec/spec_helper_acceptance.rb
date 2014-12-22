require 'beaker-rspec/spec_helper'
require 'beaker-rspec/helpers/serverspec'

UNSUPPORTED_PLATFORMS = []

unless ENV['RS_PROVISION'] == 'no' or ENV['BEAKER_provision'] == 'no'
  # This will install the latest available package on el and deb based
  # systems fail on windows and osx, and install via gem on other *nixes
  foss_opts = {:default_action => 'gem_install', :version => '3.7.1'}
  if default.is_pe?; then
    install_pe;
  else
    install_puppet(foss_opts);
  end

  hosts.each do |host|
    if host['platform'] !~ /windows/i
      on host, 'puppet master'
      on host, "mkdir -p #{host['distmoduledir']}"
    elsif host["platform"] =~ /solaris/
      on host, "echo 'export PATH=/opt/puppet/bin:/var/ruby/1.8/gem_home/bin:${PATH}' >> ~/.bashrc"
    elsif host.is_pe?
      on host, "echo 'export PATH=#{host['puppetbindir']}:${PATH}' >> ~/.bashrc"
    end
    on host, "mkdir -p #{host['distmoduledir']}"
  end
end

def create_keys_for_test(host)
  # Generate private key and CA for keystore

  if host['platform'] =~ /windows/i
    cmd = 'env PATH="$( [ -d "/cygdrive/c/Program Files (x86)/Puppet Labs/Puppet/sys/ruby/bin" ]'
    cmd += ' && echo "/cygdrive/c/Program Files (x86)" || echo "/cygdrive/c/Program Files" )/Puppet Labs/Puppet/sys/ruby/bin:${PATH}" ruby -e'
    temp_dir = 'C:\\tmp\\'
    on host, 'mkdir /cygdrive/c/tmp'
  else
    path = '${PATH}'
    path = "/opt/csw/bin:#{path}" # Need ruby's path on solaris 10 (foss)
    path = "/opt/puppet/bin:#{path}" # But try PE's ruby first
    cmd = "PATH=#{path} ruby -e"
    temp_dir = '/tmp/'
  end
  # Need to check for ruby path on puppet install, use vendor ruby and add it to the path durring execution
  tmp_privky = "#{temp_dir}privkey.pem"
  tmp_ca = "#{temp_dir}ca.pem"
  tmp_chain = "#{temp_dir}chain.pem"
  opensslscript =<<EOS
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

  chain = OpenSSL::X509::Certificate.new
  chain.serial = 1
  chain.public_key = key.public_key
  chain_subj = '/CN=Chain CA/ST=Denial/L=Springfield/O=Dis/CN=www.example.net'
  chain.subject = OpenSSL::X509::Name.parse chain_subj
  chain.issuer = chain.subject
  chain.not_before = Time.now
  chain.not_after = chain.not_before + 360
  chain.sign(key, OpenSSL::Digest::SHA256.new)

  File.open('#{tmp_privky}', 'w') { |f| f.write key.to_pem }
  File.open('#{tmp_ca}', 'w') { |f| f.write ca.to_pem }
  File.open('#{tmp_chain}', 'w') { |f| f.write chain.to_pem }
EOS
  on host, "#{cmd} \"#{opensslscript}\""
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
        exec_puppet = <<EOS
exec{'Download':
  command => 'powershell.exe -command \'(New-Object System.Net.Webclient).DownloadString("https://forge.puppetlabs.com")\'',
  path => ['c:\windows\sysnative\WindowsPowershell\v1.0','c:\windows\system32\WindowsPowershell\v1.0'],
}
EOS
        on host, apply_manifest(exec_puppet)
        on host, puppet('module install cyberious-windows_java')
      else
        on host, puppet('module install puppetlabs-java')
        on host, puppet('module', 'install', 'puppetlabs-java'), {:acceptable_exit_codes => [0, 1]}
      end
    end
  end
end

RSpec.shared_context 'common variables' do
  before {
    @ensure_ks = 'latest'
    @temp_dir = '/tmp/'
    @resource_path = "undef"
    @target = '/etc/truststore.ts'
    case fact('osfamily')
      when "Solaris"
        @keytool_path = '/usr/java/bin/'
        @resource_path = "['/usr/java/bin/','/opt/puppet/bin/']"
        @target = '/etc/truststore.ts'
      when "AIX"
        @keytool_path = '/usr/java6/bin/'
        @resource_path = "['/usr/java6/bin/','/usr/bin/']"
        @target = '/etc/truststore.ts'
      when 'windows'
        @ensure_ks = 'present'
        @keytool_path = 'C:/Java/jdk1.7.0_60/bin/'
        @target = 'c:/truststore.ts'
        @temp_dir = 'C:/tmp/'
        @resource_path = "['C:/Java/jdk1.7.0_60/bin/']"
    end
  }
end
