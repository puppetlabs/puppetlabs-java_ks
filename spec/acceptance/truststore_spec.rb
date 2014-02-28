require 'spec_helper_acceptance'

describe 'managing java truststores', :unless => UNSUPPORTED_PLATFORMS.include?(fact('operatingsystem')) do
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
  it 'creates a truststore' do
    pp = <<-EOS
      java_ks { 'puppetca:truststore':
        ensure       => latest,
        certificate  => '#{default['puppetpath']}/ssl/certs/ca.pem',
        target       => '/etc/truststore.ts',
        password     => 'puppet',
        trustcacerts => true,
        path         => #{resource_path},
    }
    EOS
    apply_manifest(pp, :catch_failures => true)
  end

  it 'verifies the truststore' do
    shell("#{keytool_path}keytool -list -v -keystore /etc/truststore.ts -storepass puppet") do |r|
      expect(r.exit_code).to be_zero
      expect(r.stdout).to match(/Your keystore contains 1 entry/)
      expect(r.stdout).to match(/Alias name: puppetca/)
      expect(r.stdout).to match(/CN=Puppet CA/)
    end
  end
end
