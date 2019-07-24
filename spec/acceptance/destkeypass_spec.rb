require 'spec_helper_acceptance'

# rubocop:disable RSpec/InstanceVariable : Instance variables are inherited and thus cannot be contained within lets

describe 'password protected java private keys', unless: UNSUPPORTED_PLATFORMS.include?(os[:family]) do
  include_context 'common variables'
  let(:target) { "#{@target_dir}destkeypass.ks" }

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

    idempotent_apply(pp)
  end

  it 'can make a cert req with the right password' do
    run_shell((keystore_certreq target), expect_failures: true) do |r|
      expect(r.exit_code).to eq(@exit_code)
      expect(r.stdout).to match(%r{-BEGIN NEW CERTIFICATE REQUEST-})
    end
  end

  it 'cannot make a cert req with the wrong password' do
    run_shell(keystore_certreq(target, 'qwert', 'qwert'), expect_failures: true)
  end
end
