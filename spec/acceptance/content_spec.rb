# frozen_string_literal: true

require 'spec_helper_acceptance'

RSpec.shared_examples 'a private key creator' do |sensitive|
  # rubocop:disable RSpec/InstanceVariable : Instance variables are inherited and thus cannot be contained within lets
  it 'creates a private key' do
    pp = if sensitive
           <<-MANIFEST
            java_ks { 'broker.example.com:#{temp_dir}private_key.ts':
              ensure              => #{@ensure_ks},
              certificate_content => "#{ca_content}",
              private_key_content => "#{priv_key_content}",
              password            => 'puppet',
              path                => #{@resource_path},
            }
           MANIFEST
         else
           <<-MANIFEST
            java_ks { 'broker.example.com:#{temp_dir}private_key.ts':
              ensure              => #{@ensure_ks},
              certificate_content => Sensitive("#{ca_content}"),
              private_key_content => Sensitive("#{priv_key_content}"),
              password            => 'puppet',
              path                => #{@resource_path},
            }
           MANIFEST
         end
    idempotent_apply(pp)
  end

  expectations = [
    %r{Alias name: broker\.example\.com},
    %r{Entry type: (keyEntry|PrivateKeyEntry)},
    %r{CN=Test CA},
  ]
  it 'verifies the private key' do
    run_shell(keytool_command("-list -v -keystore #{temp_dir}private_key.ts -storepass puppet"), expect_failures: true) do |r|
      expectations.each do |expect|
        expect(r.stdout).to match(expect)
      end
    end
  end
end

describe 'using certificate_content and private_key_content' do
  include_context 'common variables'
  let(:ca_content) { File.read('spec/acceptance/certs/ca.pem') }
  let(:priv_key_content) { File.read('spec/acceptance/certs/privkey.pem') }

  context 'Using data type String' do
    it_behaves_like 'a private key creator',  false
  end

  context 'Using data type Sensitive' do
    it_behaves_like 'a private key creator',  true
  end
  # rubocop:enable RSpec/InstanceVariable
end
