require 'spec_helper_acceptance'

describe 'managing intermediate certificates' do
  # rubocop:disable RSpec/InstanceVariable : Instance variables are inherited and thus cannot be contained within lets
  describe 'managing combined and seperate java chain keys' do
    include_context 'common variables'

    it 'creates two private key with chain certs' do
      pp = <<-MANIFEST
        java_ks { 'combined.example.com:#{@temp_dir}chain_combined_key.ks':
          ensure       => latest,
          certificate  => "#{@temp_dir}leafchain.pem",
          private_key  => "#{@temp_dir}leafkey.pem",
          password     => 'puppet',
          path         => #{@resource_path},
        }

        java_ks { 'seperate.example.com:#{@temp_dir}chain_key.ks':
          ensure       => latest,
          certificate  => "#{@temp_dir}leaf.pem",
          chain        => "#{@temp_dir}chain.pem",
          private_key  => "#{@temp_dir}leafkey.pem",
          password     => 'puppet',
          path         => #{@resource_path},
        }
      MANIFEST

      idempotent_apply(pp)
    end

    expectations_combined = [
      %r{Alias name: combined\.example\.com},
      %r{Entry type: (keyEntry|PrivateKeyEntry)},
      %r{Certificate chain length: 3},
      %r{^Serial number: 5.*^Serial number: 4.*^Serial number: 3}m,
    ]
    it 'verifies the private key #combined' do
      run_shell(keytool_command("-list -v -keystore #{@temp_dir}chain_combined_key.ks -storepass puppet"), expect_failures: true) do |r|
        expectations_combined.each do |expect|
          expect(r.stdout).to match(expect)
        end
      end
    end
    expectations_seperate = [
      %r{Alias name: seperate\.example\.com},
      %r{Entry type: (keyEntry|PrivateKeyEntry)},
      %r{Certificate chain length: 3},
      %r{^Serial number: 5.*^Serial number: 4.*^Serial number: 3}m,
    ]
    it 'verifies the private key #seperate' do
      run_shell(keytool_command("-list -v -keystore #{@temp_dir}chain_key.ks -storepass puppet"), expect_failures: true) do |r|
        expectations_seperate.each do |expect|
          expect(r.stdout).to match(expect)
        end
      end
    end

    it 'updates the two key chains' do
      pp = <<-MANIFEST
        java_ks { 'combined.example.com:#{@temp_dir}chain_combined_key.ks':
          ensure       => latest,
          certificate  => "#{@temp_dir}leafchain2.pem",
          private_key  => "#{@temp_dir}leafkey.pem",
          password     => 'puppet',
          path         => #{@resource_path},
        }

        java_ks { 'seperate.example.com:#{@temp_dir}chain_key.ks':
          ensure       => latest,
          certificate  => "#{@temp_dir}leaf.pem",
          chain        => "#{@temp_dir}chain2.pem",
          private_key  => "#{@temp_dir}leafkey.pem",
          password     => 'puppet',
          path         => #{@resource_path},
        }
      MANIFEST

      idempotent_apply(pp)

      expectations_combined = [
        %r{Alias name: combined\.example\.com},
        %r{Entry type: (keyEntry|PrivateKeyEntry)},
        %r{Certificate chain length: 2},
        %r{^Serial number: 5.*^Serial number: 6}m,
      ]
      run_shell(keytool_command("-list -v -keystore #{@temp_dir}chain_combined_key.ks -storepass puppet"), expect_failures: true) do |r|
        expectations_combined.each do |expect|
          expect(r.stdout).to match(expect)
        end
      end

      expectations_seperate = [
        %r{Alias name: seperate\.example\.com},
        %r{Entry type: (keyEntry|PrivateKeyEntry)},
        %r{Certificate chain length: 2},
        %r{^Serial number: 5.*Serial number: 6}m,
      ]
      run_shell(keytool_command("-list -v -keystore #{@temp_dir}chain_key.ks -storepass puppet"), expect_failures: true) do |r|
        expectations_seperate.each do |expect|
          expect(r.stdout).to match(expect)
        end
      end
    end
  end

  describe 'managing non existent java chain keys in noop' do
    include_context 'common variables'

    it 'does not create a new keystore in noop' do
      pp = <<-MANIFEST
        $filenames = ["#{@temp_dir}noop_ca.pem",
                      "#{@temp_dir}noop_chain.pem",
                      "#{@temp_dir}noop_privkey.pem"]
        file { $filenames:
          ensure  => file,
          content => 'content',
        } ->
        java_ks { 'broker.example.com:#{@temp_dir}noop_chain_key.ks':
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
      apply_manifest(pp, noop: true)
    end

    # verifies the dependent files are missing
    ['noop_ca.pem', 'noop_chain.pem', 'noop_privkey.pem'].each do |filename|
      describe filename do
        it "doesn't exist" do
          result = remote_file_exists?("#{@temp_dir}#{filename}")
          expect(result.exit_code).to be(1)
        end
      end
    end

    # verifies the keystore is not created
    describe 'noop_chain_key.ks' do
      it "doesn't exist" do
        result = remote_file_exists?("#{@temp_dir}noop_chain_key.ks")
        expect(result.exit_code).to be(1)
      end
    end
  end
end
