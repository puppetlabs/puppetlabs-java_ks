require 'spec_helper_system'

describe 'managing java keystores' do
  it 'creates a keystore' do
    puppet_apply(%{
      java_ks { 'puppetca:keystore':
        ensure       => latest,
        certificate  => '/var/lib/puppet/ssl/certs/ca.pem',
        target       => '/etc/keystore.ks',
        password     => 'puppet',
        trustcacerts => true,
      }
    }) { |r| [0,2].should include r.exit_code}
  end

  it 'verifies the keystore' do
    shell('keytool -list -v -keystore /etc/keystore.ks -storepass puppet') do |r|
      expect(r.exit_code).to be_zero
      expect(r.stdout).to match(/Your keystore contains 1 entry/)
      expect(r.stdout).to match(/Alias name: puppetca/)
      expect(r.stdout).to match(/CN=Puppet CA/)
    end
  end
end
