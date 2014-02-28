require 'spec_helper_acceptance'

hostname = default.node_name

describe 'managing java private keys', :unless => UNSUPPORTED_PLATFORMS.include?(fact('operatingsystem')) do
  let(:confdir)    { default['puppetpath']    }
  let(:modulepath) { default['distmoduledir'] }
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
  it 'creates a private key' do
    pp = <<-EOS
      java_ks { 'broker.example.com:/etc/private_key.ks':
        ensure       => latest,
        certificate  => "#{confdir}/ssl/certs/#{hostname}.pem",
        private_key  => "#{confdir}/ssl/private_keys/#{hostname}.pem",
        password     => 'puppet',
        path         => #{resource_path},
      }
    EOS

    apply_manifest(pp, :catch_failures => true)
  end

  it 'verifies the private key' do
    shell("#{keytool_path}keytool -list -v -keystore /etc/private_key.ks -storepass puppet") do |r|
      expect(r.exit_code).to be_zero
      expect(r.stdout).to match(/Alias name: broker\.example\.com/)
      expect(r.stdout).to match(/Entry type: (keyEntry|PrivateKeyEntry)/)
      expect(r.stdout).to match(/CN=Puppet CA/)
    end
  end

  describe 'from a puppet:// uri' do
    it 'puts a key in a module' do
      pp = <<-EOS
        file { [
          '#{modulepath}/keys',
          '#{modulepath}/keys/files',
        ]:
          ensure => directory,
        }
        file { '#{modulepath}/keys/files/ca.pem':
          ensure => file,
          source => '#{confdir}/ssl/certs/ca.pem',
        }
        file { '#{modulepath}/keys/files/certificate.pem':
          ensure => file,
          source => '#{confdir}/ssl/certs/#{hostname}.pem',
        }
        file { '#{modulepath}/keys/files/private_key.pem':
          ensure => file,
          source => '#{confdir}/ssl/private_keys/#{hostname}.pem',
        }
      EOS

      apply_manifest(pp, :catch_failures => true)
    end

    it 'creates a keystore' do
      pp = <<-EOS
        java_ks { 'uri.example.com:/etc/uri_key.ks':
          ensure       => latest,
          certificate  => 'puppet:///modules/keys/certificate.pem',
          private_key  => 'puppet:///modules/keys/private_key.pem',
          chain        => 'puppet:///modules/keys/ca.pem',
          password     => 'puppet',
          path         => #{resource_path},
        }
      EOS

      apply_manifest(pp, :catch_failures => true)
    end

    it 'verifies the private key' do
      shell("#{keytool_path}keytool -list -v -keystore /etc/uri_key.ks -storepass puppet") do |r|
        expect(r.exit_code).to be_zero
        expect(r.stdout).to match(/Alias name: uri\.example\.com/)
        expect(r.stdout).to match(/Entry type: (keyEntry|PrivateKeyEntry)/)
        expect(r.stdout).to match(/CN=Puppet CA/)
      end
    end
  end
end
