require 'spec_helper_acceptance'

describe 'prep nodes', :unless => UNSUPPORTED_PLATFORMS.include?(fact('operatingsystem')) do
  it 'requires java', :unless => ["Solaris", "AIX"].include?(fact('osfamily')) do
    java_source = ENV['JAVA_DOWNLOAD_SOURCE'] || "http://download.oracle.com/otn-pub/java/jdk/7u67-b01/jdk-7u67-windows-x64.exe"
    pp = <<-EOS
    if $::osfamily !~ /windows/ {
		    class { 'java': }
      } else {
		  windows_java::jdk{'JDK 7u67':
			  ensure       => 'present',
			  install_name => 'Java SE Development Kit 7 Update 67 (64-bit)',
			  source       => '#{java_source}',
			  install_path => 'C:\\Java\\jdk1.7.0_67',
			  jre_install_path => 'C:\\Java\\jre',
	    }
    }
    EOS
    apply_manifest(pp, :catch_failures => true)
  end
end
