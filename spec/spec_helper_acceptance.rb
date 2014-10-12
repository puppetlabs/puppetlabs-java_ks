require 'beaker-rspec/spec_helper'
require 'beaker-rspec/helpers/serverspec'

UNSUPPORTED_PLATFORMS = []

unless ENV['RS_PROVISION'] == 'no' or ENV['BEAKER_provision'] == 'no'
  if hosts.first.is_pe?
    install_pe
  else
    install_puppet
  end
  hosts.each do |host|
    if host['platform'] !~ /windows/i
      on host, 'puppet master'
      on host, "mkdir -p #{host['distmoduledir']}"
    end
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
    hosts.each do |host|
      #install java if windows
      if host['platform'] =~ /windows/i
        on host, 'powershell.exe -command "(New-Object System.Net.Webclient).DownloadString(\'https://forge.puppetlabs.com\')"'
        on host, puppet('module install cyberious-windows_java')
      else
        on host, puppet('module install puppetlabs-java')
      end
      copy_module_to(host, :source => proj_root, :module_name => 'java_ks')
    end
  end
end
