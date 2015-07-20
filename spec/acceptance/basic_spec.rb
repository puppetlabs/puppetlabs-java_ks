require 'spec_helper_acceptance'

describe 'prep nodes', :unless => UNSUPPORTED_PLATFORMS.include?(fact('operatingsystem')) do
  it 'requires java', :unless => ["Solaris", "AIX"].include?(fact('osfamily')) do
    java_source = ENV['JAVA_DOWNLOAD_SOURCE'] || "http://download.oracle.com/otn-pub/java/jdk/7u67-b01/jdk-7u67-windows-x64.exe"
    java_major, java_minor = (ENV['JAVA_VERSION'] || '7u67').split('u')
    pp = <<-EOS
if $::osfamily !~ /windows/ {
  class { 'java': }
} else {
  windows_java::jdk{'JDK #{java_major}u#{java_minor}':
	  ensure       => 'present',
		install_name => 'Java SE Development Kit #{java_major} Update #{java_minor} (64-bit)',
		source       => '#{java_source}',
		install_path => 'C:\\Java\\jdk1.#{java_major}.0_#{java_minor}',
  }
}
    EOS
    apply_manifest(pp, :catch_failures => true)
  end
end
