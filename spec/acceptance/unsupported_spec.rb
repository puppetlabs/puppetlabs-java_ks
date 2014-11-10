require 'spec_helper_acceptance'

describe 'unsupported distributions and OSes', :if => UNSUPPORTED_PLATFORMS.include?(fact('operatingsystem')) do
  case fact('osfamily')
  when "Solaris"
    keytool_path = '/usr/java/bin/'
    resource_path = "['/usr/java/bin/','/opt/puppet/bin/','/usr/bin/']"
  when "AIX"
    keytool_path = '/usr/java6/bin/'
    resource_path = "['/usr/java6/bin/','/opt/puppet/bin/']"
  else
    resource_path = "undef"
  end
  it 'should fail' do
    pp = <<-EOS
    java_ks { 'puppetca:keystore':
      ensure       => latest,
      certificate  => "/tmp/ca.pem",
      target       => '/etc/keystore.ks',
      password     => 'puppet',
      trustcacerts => true,
      path         => #{resource_path},
    }
    EOS
    expect(apply_manifest(pp, :expect_failures => true).stderr).to match(/unsupported os/)
  end
end
