require 'spec_helper_acceptance'

describe 'password protected java private keys', unless: UNSUPPORTED_PLATFORMS.include?(fact('operatingsystem')) do
  # rubocop:disable RSpec/InstanceVariable : Instance variables are inherited and thus cannot be contained within lets
  include_context 'common variables'
  target = "#{@target_dir}destkeypass.ks"

  it 'creates a password protected private key' do
    pp = <<-MANIFEST
      java_ks { 'broker.example.com:#{target}':
        ensure       => latest,
        certificate  => "#{@temp_dir}ca.pem",
        private_key  => "#{@temp_dir}privkey.pem",
        password     => 'testpass',
        destkeypass  => 'testkeypass',
        path         => #{@resource_path},
      }
    MANIFEST

    apply_manifest(pp, catch_failures: true)
    apply_manifest(pp, catch_changes: true)
  end

  it 'can make a cert req with the right password #zero' do
    shell("\"#{@keytool_path}keytool\" -certreq -alias broker.example.com -v "\
     "-keystore #{target} -storepass testpass -keypass testkeypass") do |r|
      expect(r.exit_code).to be_zero
    end
  end
  it 'can make a cert req with the right password #regex' do
    shell("\"#{@keytool_path}keytool\" -certreq -alias broker.example.com -v "\
     "-keystore #{target} -storepass testpass -keypass testkeypass") do |r|
      expect(r.stdout).to match(%r{-BEGIN NEW CERTIFICATE REQUEST-})
    end
  end

  it 'cannot make a cert req with the wrong password' do
    shell("\"#{@keytool_path}keytool\" -certreq -alias broker.example.com -v "\
     "-keystore #{target} -storepass qwert -keypass qwert",
          acceptable_exit_codes: 1)
  end
end
