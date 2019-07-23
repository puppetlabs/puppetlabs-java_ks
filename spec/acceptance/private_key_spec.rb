require 'spec_helper_acceptance'

# rubocop:disable RSpec/InstanceVariable : Instance variables are inherited and thus cannot be contained within lets

describe 'managing java private keys', unless: UNSUPPORTED_PLATFORMS.include?(os[:family]) do
  def keystore_command(target)
    command = "\"#{@keytool_path}keytool\" -list -v -keystore #{target} -storepass puppet"
    command.prepend('& ') if os[:family] == 'windows'
    command
  end

  include_context 'common variables'
  let(:target) { "#{@target_dir}private_key.ts" }

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

    idempotent_apply(pp)
  end

  expectations = [
    %r{Alias name: broker\.example\.com},
    %r{Entry type: (keyEntry|PrivateKeyEntry)},
    %r{CN=Test CA},
  ]
  it 'verifies the private key' do
    run_shell((keystore_command target), expect_failures: true) do |r|
      expect(r.exit_code).to eq(@exit_code)
      expectations.each do |expect|
        expect(r.stdout).to match(expect)
      end
    end
  end
end
