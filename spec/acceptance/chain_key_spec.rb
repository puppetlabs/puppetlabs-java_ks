require 'spec_helper_acceptance'

describe 'managing intermediate certificates' do
  # rubocop:disable RSpec/InstanceVariable : Instance variables are inherited and thus cannot be contained within lets
  describe 'managing combined and seperate java chain keys', unless: UNSUPPORTED_PLATFORMS.include?(host_inventory['facter']['os']['name']) do
    include_context 'common variables'
    target_combined = "#{@target_dir}chain_combined_key.ks"
    target_seperate = "#{@target_dir}chain_key.ks"

    it 'creates a private key with chain certs' do
      pp = <<-MANIFEST
        java_ks { 'combined.example.com:#{target_combined}':
          ensure       => latest,
          certificate  => "#{@temp_dir}leafchain.pem",
          private_key  => "#{@temp_dir}leafkey.pem",
          password     => 'puppet',
          path         => #{@resource_path},
        }
        java_ks { 'seperate.example.com:#{target_seperate}':
          ensure       => latest,
          certificate  => "#{@temp_dir}leaf.pem",
          chain        => "#{@temp_dir}chain.pem",
          private_key  => "#{@temp_dir}leafkey.pem",
          password     => 'puppet',
          path         => #{@resource_path},
        }
      MANIFEST

      idempotent_apply(default, pp)
    end

    expectations_combined = [
      %r{Alias name: combined\.example\.com},
      %r{Entry type: (keyEntry|PrivateKeyEntry)},
      %r{Certificate chain length: 3},
      %r{^Serial number: 5$.*^Serial number: 4$.*^Serial number: 3$}m,
    ]
    it 'verifies the private key #combined' do
      shell("\"#{@keytool_path}keytool\" -list -v -keystore #{target_combined} -storepass puppet") do |r|
        expect(r.exit_code).to be_zero
        expectations_combined.each do |expect|
          expect(r.stdout).to match(expect)
        end
      end
    end
    expectations_seperate = [
      %r{Alias name: seperate\.example\.com},
      %r{Entry type: (keyEntry|PrivateKeyEntry)},
      %r{Certificate chain length: 3},
      %r{^Serial number: 5$.*^Serial number: 4$.*^Serial number: 3$}m,
    ]
    it 'verifies the private key #seperate' do
      shell("\"#{@keytool_path}keytool\" -list -v -keystore #{target_seperate} -storepass puppet") do |r|
        expect(r.exit_code).to be_zero
        expectations_seperate.each do |expect|
          expect(r.stdout).to match(expect)
        end
      end
    end

    it 'updates the chain' do
      pp = <<-MANIFEST
        java_ks { 'combined.example.com:#{target_combined}':
          ensure       => latest,
          certificate  => "#{@temp_dir}leafchain2.pem",
          private_key  => "#{@temp_dir}leafkey.pem",
          password     => 'puppet',
          path         => #{@resource_path},
        }
        java_ks { 'seperate.example.com:#{target_seperate}':
          ensure       => latest,
          certificate  => "#{@temp_dir}leaf.pem",
          chain        => "#{@temp_dir}chain2.pem",
          private_key  => "#{@temp_dir}leafkey.pem",
          password     => 'puppet',
          path         => #{@resource_path},
        }
      MANIFEST

      idempotent_apply(default, pp)

      expectations_combined = [
        %r{Alias name: combined\.example\.com},
        %r{Entry type: (keyEntry|PrivateKeyEntry)},
        %r{Certificate chain length: 2},
        %r{^Serial number: 5$.*^Serial number: 6$}m,
      ]
      shell("\"#{@keytool_path}keytool\" -list -v -keystore #{target_combined} -storepass puppet") do |r|
        expect(r.exit_code).to be_zero
        expectations_combined.each do |expect|
          expect(r.stdout).to match(expect)
        end
      end

      expectations_seperate = [
        %r{Alias name: seperate\.example\.com},
        %r{Entry type: (keyEntry|PrivateKeyEntry)},
        %r{Certificate chain length: 2},
        %r{^Serial number: 5$.*^Serial number: 6$}m,
      ]
      shell("\"#{@keytool_path}keytool\" -list -v -keystore #{target_seperate} -storepass puppet") do |r|
        expect(r.exit_code).to be_zero
        expectations_seperate.each do |expect|
          expect(r.stdout).to match(expect)
        end
      end
    end
  end

  describe 'managing non existent java chain keys in noop', unless: UNSUPPORTED_PLATFORMS.include?(host_inventory['facter']['os']['name']) do
    include_context 'common variables'
    target = "#{@target_dir}noop_chain_key.ks"

    it 'does not create a new keystore in noop' do
      pp = <<-MANIFEST
        $filenames = ["#{@temp_dir}noop_ca.pem",
                      "#{@temp_dir}noop_chain.pem",
                      "#{@temp_dir}noop_privkey.pem"]
        file { $filenames:
          ensure  => file,
          content => 'content',
        } ->
        java_ks { 'broker.example.com:#{target}':
          ensure       => latest,
          certificate  => "#{@temp_dir}noop_ca.pem",
          chain        => "#{@temp_dir}noop_chain.pem",
          private_key  => "#{@temp_dir}noop_privkey.pem",
          password     => 'puppet',
          path         => #{@resource_path},
        }
      MANIFEST

      # in noop mode, when the dependent certificate files are not present in the system,
      # java_ks will not invoke openssl to validate their status, thus noop will succeed
      apply_manifest(pp, catch_failures: true, noop: true)
    end

    # verifies the dependent files are missing
    ["#{@temp_dir}noop_ca.pem", "#{@temp_dir}noop_chain.pem", "#{@temp_dir}noop_privkey.pem"].each do |filename|
      describe file(filename.to_s) do
        it { is_expected.not_to be_file }
      end
    end

    # verifies the keystore is not created
    describe file(target.to_s) do
      it { is_expected.not_to be_file }
    end
  end
end
