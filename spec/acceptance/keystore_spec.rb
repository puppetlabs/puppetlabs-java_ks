require 'spec_helper_acceptance'

describe 'managing java keystores', :unless => UNSUPPORTED_PLATFORMS.include?(fact('operatingsystem')) do
  case fact('osfamily')
  when "Solaris"
    keytool_path = '/usr/java/bin/'
    resource_path = "['/usr/java/bin/','/opt/puppet/bin/']"
  when "AIX"
    keytool_path = '/usr/java6/bin/'
    resource_path = "['/usr/java6/bin/','/usr/bin/']"
  else
    resource_path = "undef"
  end
  it 'creates a keystore' do
    pp = <<-EOS
      java_ks { 'puppetca:keystore':
        ensure       => latest,
        certificate  => '#{default['puppetpath']}/ssl/certs/ca.pem',
        target       => '/etc/keystore.ks',
        password     => 'puppet',
        trustcacerts => true,
        path         => #{resource_path},
      }
    EOS

    apply_manifest(pp, :catch_failures => true)
  end

  it 'verifies the keystore' do
    shell("#{keytool_path}keytool -list -v -keystore /etc/keystore.ks -storepass puppet") do |r|
      expect(r.exit_code).to be_zero
      expect(r.stdout).to match(/Your keystore contains 1 entry/)
      expect(r.stdout).to match(/Alias name: puppetca/)
      expect(r.stdout).to match(/CN=Puppet CA/)
    end
  end
end
