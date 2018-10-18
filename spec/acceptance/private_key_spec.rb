require 'spec_helper_acceptance'

describe 'managing java private keys', unless: UNSUPPORTED_PLATFORMS.include?(fact('operatingsystem')) do
  # rubocop:disable RSpec/InstanceVariable : Instance variables are inherited and thus cannot be contained within lets
  include_context 'common variables'
  target = "#{@target_dir}private_key.ts"

  it 'creates a private key' do
    pp = <<-MANIFEST
      java_ks { 'broker.example.com:#{target}':
        ensure       => #{@ensure_ks},
        certificate  => "#{@temp_dir}ca.pem",
        private_key  => "#{@temp_dir}privkey.pem",
        password     => 'puppet',
        path         => #{@resource_path},
      }
    MANIFEST

    apply_manifest(pp, catch_failures: true)
    apply_manifest(pp, catch_changes: true)
  end

  expectations = [
    %r{Alias name: broker\.example\.com},
    %r{Entry type: (keyEntry|PrivateKeyEntry)},
    %r{CN=Test CA},
  ]
  it 'verifies the private key #zero' do
    shell("\"#{@keytool_path}keytool\" -list -v -keystore #{target} -storepass puppet") do |r|
      expect(r.exit_code).to be_zero
    end
  end
  it 'verifies the private key #expected' do
    shell("\"#{@keytool_path}keytool\" -list -v -keystore #{target} -storepass puppet") do |r|
      expectations.each do |expect|
        expect(r.stdout).to match(expect)
      end
    end
  end
end
