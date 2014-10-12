require 'spec_helper_acceptance'

hostname = default.node_name
UNSUPPORTED_PRIVATE_KEY = UNSUPPORTED_PLATFORMS + ['windows']
describe 'managing java private keys', :unless => UNSUPPORTED_PRIVATE_KEY.include?(fact('operatingsystem')) do
  let(:confdir) { default['puppetpath'] }
  let(:modulepath) { default['distmoduledir'] }
  case fact('osfamily')
    when "Solaris"
      keytool_path = '/usr/java/bin/'
      resource_path = "['/usr/java/bin/','/opt/puppet/bin/','/usr/bin/']"
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
        certificate  => "${settings::ssldir}/certs/#{hostname}.pem",
        private_key  => "${settings::ssldir}/private_keys/#{hostname}.pem",
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
end
