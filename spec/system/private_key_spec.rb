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

  describe 'from a puppet:// uri' do
    it 'puts a key in a module' do
      puppet_apply(%{
        file { [
          '/etc/puppet/modules/keys',
          '/etc/puppet/modules/keys/files',
        ]:
          ensure => directory,
        }
        file { '/etc/puppet/modules/keys/files/ca.pem':
          ensure => file,
          source => '/var/lib/puppet/ssl/certs/ca.pem',
        }
        file { '/etc/puppet/modules/keys/files/certificate.pem':
          ensure => file,
          source => '/var/lib/puppet/ssl/certs/main.foo.vm.pem',
        }
        file { '/etc/puppet/modules/keys/files/private_key.pem':
          ensure => file,
          source => '/var/lib/puppet/ssl/private_keys/main.foo.vm.pem',
        }
      }) { |r| [0,2].should include r.exit_code}
    end

    it 'creates a keystore' do
      puppet_apply(%{
        java_ks { 'uri.example.com:/etc/uri_key.ks':
          ensure       => latest,
          certificate  => 'puppet:///modules/keys/certificate.pem',
          private_key  => 'puppet:///modules/keys/private_key.pem',
          chain        => 'puppet:///modules/keys/ca.pem',
          password     => 'puppet',
        }
      }) { |r| [0,2].should include r.exit_code}
    end

    it 'verifies the private key' do
      shell('keytool -list -v -keystore /etc/uri_key.ks -storepass puppet') do |r|
        expect(r.exit_code).to be_zero
        expect(r.stdout).to match(/Alias name: uri\.example\.com/)
        expect(r.stdout).to match(/Entry type: PrivateKeyEntry/)
        expect(r.stdout).to match(/CN=Puppet CA/)
      end
    end
  end
end
