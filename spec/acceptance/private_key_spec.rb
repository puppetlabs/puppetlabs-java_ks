require 'spec_helper_acceptance'

hostname = default.node_name

describe 'managing java private keys' do
  it 'creates a private key' do
    pp = <<-EOS
      class { 'java': }
      java_ks { 'broker.example.com:/etc/private_key.ks':
        ensure       => latest,
        certificate  => "/etc/puppet/ssl/certs/#{hostname}.pem",
        private_key  => "/etc/puppet/ssl/private_keys/#{hostname}.pem",
        password     => 'puppet',
      }
    EOS

    apply_manifest(pp, :catch_failures => true)
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
      pp = <<-EOS
        class { 'java': }
        file { [
          '/etc/puppet/modules/keys',
          '/etc/puppet/modules/keys/files',
        ]:
          ensure => directory,
        }
        file { '/etc/puppet/modules/keys/files/ca.pem':
          ensure => file,
          source => '/etc/puppet/ssl/certs/ca.pem',
        }
        file { '/etc/puppet/modules/keys/files/certificate.pem':
          ensure => file,
          source => '/etc/puppet/ssl/certs/#{hostname}.pem',
        }
        file { '/etc/puppet/modules/keys/files/private_key.pem':
          ensure => file,
          source => '/etc/puppet/ssl/private_keys/#{hostname}.pem',
        }
      EOS

      apply_manifest(pp, :catch_failures => true)
    end

    it 'creates a keystore' do
      pp = <<-EOS
        class { 'java': }
        java_ks { 'uri.example.com:/etc/uri_key.ks':
          ensure       => latest,
          certificate  => 'puppet:///modules/keys/certificate.pem',
          private_key  => 'puppet:///modules/keys/private_key.pem',
          chain        => 'puppet:///modules/keys/ca.pem',
          password     => 'puppet',
        }
      EOS

      apply_manifest(pp, :catch_failures => true)
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
