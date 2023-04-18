# frozen_string_literal: true

require 'spec_helper_acceptance'

describe 'password protected java private keys', unless: UNSUPPORTED_PLATFORMS.include?(os[:family]) do
  # rubocop:disable RSpec/InstanceVariable : Instance variables are inherited and thus cannot be contained within lets
  include_context 'common variables'
  target = "#{@target_dir}destkeypass.ks"

  it 'creates a password protected private key' do
    pp = <<-MANIFEST
      java_ks { 'broker.example.com:#{@temp_dir}#{target}':
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
    run_shell(keytool_command('-certreq -alias broker.example.com -v ' \
                              "-keystore #{@temp_dir}#{target} -storepass testpass -keypass testkeypass"), expect_failures: true) do |r|
      expect(r.stdout).to match(%r{-BEGIN NEW CERTIFICATE REQUEST-})
    end
  end

  it 'cannot make a cert req with the wrong password' do
    result = run_shell(keytool_command('-certreq -alias broker.example.com -v ' \
                                       "-keystore #{@temp_dir}#{target} -storepass qwert -keypass qwert"), expect_failures: true)
    expect(result.stdout).to match(%r{keytool error})
  end
end
