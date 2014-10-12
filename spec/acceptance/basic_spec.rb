require 'spec_helper_acceptance'

describe 'prep nodes', :unless => UNSUPPORTED_PLATFORMS.include?(fact('operatingsystem')) do
  it 'requires java', :unless => ["Solaris", "AIX"].include?(fact('osfamily')) do
    pp = <<-EOS
    if $::osfamily !~ /windows/ {
		    class { 'java': }
      } else {
		  windows_java::jdk{'JDK 7u60':
			  ensure       => 'present',
			  install_name => 'Java SE Development Kit 7 Update 60 (64-bit)',
			  source       => "http://download.oracle.com/otn-pub/java/jdk/7u60-b19/jdk-7u60-windows-x64.exe",
			  install_path => 'C:\\Java\\jdk1.7.0_60',
			  jre_install_path => 'C:\\Java\\jre',
	    }
    }
    EOS
    apply_manifest(pp, :catch_failures => true)
  end
end
