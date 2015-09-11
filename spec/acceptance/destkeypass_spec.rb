require 'spec_helper_acceptance'

hostname = default.node_name

describe 'password protected java private keys', :unless => UNSUPPORTED_PLATFORMS.include?(fact('operatingsystem')) do
  include_context 'common variables'

  let(:confdir)    { default['puppetpath']    }
  let(:modulepath) { default['distmoduledir'] }

  case fact('osfamily')
    when "windows"
      target = 'c:/private_key.ks'
    else
      target = '/etc/private_key.ks'
  end

  it 'creates a password protected private key' do
    pp = <<-EOS
      java_ks { 'broker.example.com:#{target}':
        ensure       => latest,
        certificate  => "#{@temp_dir}ca.pem",
        private_key  => "#{@temp_dir}privkey.pem",
        password     => 'testpass',
        destkeypass  => 'testkeypass',
        path         => #{@resource_path},
      }
    EOS

    apply_manifest(pp, :catch_failures => true)
  end

  it 'can make a cert req with the right password' do
    shell("#{@keytool_path}keytool -certreq -alias broker.example.com -v "\
     "-keystore #{target} -storepass testpass -keypass testkeypass") do |r|
      expect(r.exit_code).to be_zero
      expect(r.stdout).to match(/-BEGIN NEW CERTIFICATE REQUEST-/)
    end
  end

  it 'cannot make a cert req with the wrong password' do
    shell("#{@keytool_path}keytool -certreq -alias broker.example.com -v "\
     "-keystore #{target} -storepass testpass -keypass qwert",
     :acceptable_exit_codes => 1)
  end

end
