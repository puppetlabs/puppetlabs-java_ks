# frozen_string_literal: true

require 'spec_helper_acceptance'

describe 'managing java private keys' do
  # rubocop:disable RSpec/InstanceVariable : Instance variables are inherited and thus cannot be contained within lets
  include_context 'common variables'

  it 'creates a private key' do
    pp = <<-MANIFEST
      java_ks { 'broker.example.com:#{@temp_dir}private_key.ts':
        ensure       => #{@ensure_ks},
        certificate  => "#{@temp_dir}ca.pem",
        private_key  => "#{@temp_dir}privkey.pem",
        password     => 'puppet',
        path         => #{@resource_path},
      }
    MANIFEST

    idempotent_apply(pp)
  end

  expectations = [
    %r{Alias name: broker\.example\.com},
    %r{Entry type: (keyEntry|PrivateKeyEntry)},
    %r{CN=Test CA},
  ]
  it 'verifies the private key' do
    run_shell(keytool_command("-list -v -keystore #{@temp_dir}private_key.ts -storepass puppet"), expect_failures: true) do |r|
      expectations.each do |expect|
        expect(r.stdout).to match(expect)
      end
    end
  end
  # rubocop:enable RSpec/InstanceVariable
end
