require 'spec_helper_acceptance'

hostname = default.node_name

describe 'password protected java private keys', :unless => UNSUPPORTED_PLATFORMS.include?(fact('operatingsystem')) do
  let(:confdir)    { default['puppetpath']    }
  let(:modulepath) { default['distmoduledir'] }
  case fact('osfamily')
  when "Solaris"
    keytool_path = '/usr/java/bin/'
    resource_path = "['/usr/java/bin/','/opt/puppet/bin/', '/usr/bin']"
  when "AIX"
    keytool_path = '/usr/java6/bin/'
    resource_path = "['/usr/java6/bin/','/usr/bin/']"
  else
    resource_path = "undef"
  end
  it 'creates a password protected private key' do
    pp = <<-EOS
      java_ks { 'broker.example.com:/etc/private_key.ks':
        ensure       => latest,
        certificate  => "/tmp/ca.pem",
        private_key  => "/tmp/privkey.pem",
        password     => 'testpass',
        destkeypass  => 'testkeypass',
        path         => #{resource_path},
      }
    EOS

    apply_manifest(pp, :catch_failures => true)
  end

  it 'can make a cert req with the right password' do
    shell("#{keytool_path}keytool -certreq -alias broker.example.com -v "\
     "-keystore /etc/private_key.ks -storepass testpass -keypass testkeypass") do |r|
      expect(r.exit_code).to be_zero
      expect(r.stdout).to match(/-BEGIN NEW CERTIFICATE REQUEST-/)
    end
  end

  it 'cannot make a cert req with the wrong password' do
    shell("#{keytool_path}keytool -certreq -alias broker.example.com -v "\
     "-keystore /etc/private_key.ks -storepass testpass -keypass qwert",
     :acceptable_exit_codes => 1)
  end

end
