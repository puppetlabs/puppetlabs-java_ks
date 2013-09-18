require 'spec_helper_system'

describe 'managing java private keys' do
  it 'creates a private key' do
    puppet_apply(%{
      java_ks { 'broker.example.com:/etc/private_key.ks':
        ensure       => latest,
        certificate  => '/var/lib/puppet/ssl/certs/main.foo.vm.pem',
        private_key  => '/var/lib/puppet/ssl/private_keys/main.foo.vm.pem',
        password     => 'puppet',
      }
    }) { |r| [0,2].should include r.exit_code}
  end

  it 'verifies the private key' do
    shell('keytool -list -v -keystore /etc/private_key.ks -storepass puppet') do |r|
      expect(r.exit_code).to be_zero
      expect(r.stdout).to match(/Alias name: broker\.example\.com/)
      expect(r.stdout).to match(/Entry type: PrivateKeyEntry/)
      expect(r.stdout).to match(/CN=Puppet CA/)
    end
  end
end
