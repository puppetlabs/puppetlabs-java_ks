require 'beaker-rspec/spec_helper'
require 'beaker-rspec/helpers/serverspec'

UNSUPPORTED_PLATFORMS = []

unless ENV['RS_PROVISION'] == 'no' or ENV['BEAKER_provision'] == 'no'
  # This will install the latest available package on el and deb based
  # systems fail on windows and osx, and install via gem on other *nixes
  foss_opts = { :default_action => 'gem_install' }

  if default.is_pe?; then install_pe; else install_puppet( foss_opts ); end

  hosts.each do |host|
    if host["platform"] =~ /solaris/
      on host, "echo 'export PATH=/opt/puppet/bin:/var/ruby/1.8/gem_home/bin:${PATH}' >> ~/.bashrc"
    elsif host.is_pe?
      on host, "echo 'export PATH=#{host['puppetbindir']}:${PATH}' >> ~/.bashrc"
    end
    on host, "mkdir -p #{host['distmoduledir']}"
  end
end

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

  File.open('/tmp/privkey.pem', 'w') { |f| f.write key.to_pem }
  File.open('/tmp/ca.pem', 'w') { |f| f.write ca.to_pem }
EOS

RSpec.configure do |c|
  # Project root
  proj_root = File.expand_path(File.join(File.dirname(__FILE__), '..'))

  # Readable test descriptions
  c.formatter = :documentation

  # Configure all nodes in nodeset
  c.before :suite do
    # Install module and dependencies
    hosts.each do |host|
      copy_module_to(host, :source => proj_root, :module_name => 'java_ks')
      on host, puppet('module', 'install', 'puppetlabs-java'), { :acceptable_exit_codes => [0,1] }
      # Generate private key and CA for keystore
      if host.is_pe?
        on host, "#{host['puppetbindir']}/ruby -e \"#{opensslscript}\""
      else
        on host, "ruby -e \"#{opensslscript}\""
      end
    end
  end
end
