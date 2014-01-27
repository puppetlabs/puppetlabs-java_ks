require 'beaker-rspec/spec_helper'
require 'beaker-rspec/helpers/serverspec'

hosts.each do |host|
  if host['platform'] =~ /debian/
    on host, 'echo \'export PATH=/var/lib/gems/1.8/bin/:${PATH}\' >> ~/.bashrc'
  end
  if host.is_pe?
    install_pe
  else
    # Install Puppet
    install_package host, 'rubygems'
    on host, 'gem install puppet --no-ri --no-rdoc'
    on host, "mkdir -p #{host['distmoduledir']}"
    # Create certs for keystore tests.
    on host, 'puppet master --no-daemonize --verbose &'
    #on host, 'killall -9 puppet'
  end
end

RSpec.configure do |c|
  # Project root
  proj_root = File.expand_path(File.join(File.dirname(__FILE__), '..'))

  # Readable test descriptions
  c.formatter = :documentation

  # Configure all nodes in nodeset
  c.before :suite do
    # Install module and dependencies
    puppet_module_install(:source => proj_root, :module_name => 'java_ks')
    hosts.each do |host|
      shell('puppet module install puppetlabs-java --version 1.0.1')
    end
  end
end
