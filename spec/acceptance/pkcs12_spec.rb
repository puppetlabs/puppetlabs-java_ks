require 'spec_helper_acceptance'

# rubocop:disable RSpec/InstanceVariable : Instance variables are inherited and thus cannot be contained within lets

# SLES by default does not support this form of encyrption.
describe 'managing java pkcs12', unless: (UNSUPPORTED_PLATFORMS.include?(os[:family]) || os[:family] == 'SLES') do
  include_context 'common variables'

  context 'with defaults' do
    let(:target) { "#{@target_dir}pcks12.ks" }

    it 'creates a private key with chain' do
      pp = <<-MANIFEST
        java_ks { 'Leaf Cert:#{target}':
          ensure          => #{@ensure_ks},
          certificate     => "#{@temp_dir}leaf.p12",
          storetype       => 'pkcs12',
          password        => 'puppet',
          path            => #{@resource_path},
          source_password => 'pkcs12pass'
        }
      MANIFEST

      idempotent_apply(pp)
    end

    expectations = [
      %r{Alias name: leaf cert},
      %r{Entry type: (keyEntry|PrivateKeyEntry)},
      %r{Certificate chain length: 3},
      %r{Serial number: 5}m,
    ]
    it 'verifies the private key and chain' do
      run_shell((keystore_list target), expect_failures: true) do |r|
        expect(r.exit_code).to eq(@exit_code)
        expectations.each do |expect|
          expect(r.stdout).to match(expect)
        end
      end
    end

    it 'updates the chain' do
      pp = <<-MANIFEST
        java_ks { 'Leaf Cert:#{target}':
            ensure          => #{@ensure_ks},
            certificate     => "#{@temp_dir}leaf2.p12",
            storetype       => 'pkcs12',
            password        => 'puppet',
            path            => #{@resource_path},
            source_password => 'pkcs12pass'
        }
      MANIFEST

      idempotent_apply(pp)

      expectations = if os[:family] == 'windows'
                       [
                         %r{Alias name: leaf cert},
                         %r{Entry type: (keyEntry|PrivateKeyEntry)},
                         %r{Certificate chain length: 3},
                         %r{Serial number: 3}m,
                         %r{Serial number: 4}m,
                         %r{Serial number: 5}m,
                       ]
                     else
                       [
                         %r{Alias name: leaf cert},
                         %r{Entry type: (keyEntry|PrivateKeyEntry)},
                         %r{Certificate chain length: 2},
                         %r{^Serial number: 5$.*^Serial number: 6$}m,
                       ]
                     end
      run_shell((keystore_list target), expect_failures: true) do |r|
        expect(r.exit_code).to eq(@exit_code)
        expectations.each do |expect|
          expect(r.stdout).to match(expect)
        end
      end
    end
  end # context 'with defaults'

  context 'with a different alias' do
    let(:target) { "#{@target_dir}pcks12-2.ks" }

    it 'creates a private key with chain' do
      pp = <<-MANIFEST
        java_ks { 'Leaf_Cert:#{target}':
          ensure          => #{@ensure_ks},
          certificate     => "#{@temp_dir}leaf.p12",
          storetype       => 'pkcs12',
          password        => 'puppet',
          path            => #{@resource_path},
          source_password => 'pkcs12pass',
          source_alias    => 'Leaf Cert'
        }
      MANIFEST

      idempotent_apply(pp)
    end

    expectations = [
      %r{Alias name: leaf_cert},
      %r{Entry type: (keyEntry|PrivateKeyEntry)},
      %r{Certificate chain length: 3},
      %r{Serial number: 5},
      %r{Serial number: 4},
      %r{Serial number: 3},
    ]
    it 'verifies the private key and chain' do
      run_shell((keystore_list target), expect_failures: true) do |r|
        expect(r.exit_code).to eq(@exit_code)
        expectations.each do |expect|
          expect(r.stdout).to match(expect)
        end
      end
    end
  end # context 'with a different alias'

  context 'with a destkeypass' do
    let(:target) { "#{@target_dir}pcks12-2.ks" }

    it 'creates a private key with chain' do
      pp = <<-MANIFEST
        java_ks { 'Leaf_Cert:#{target}':
          ensure          => #{@ensure_ks},
          certificate     => "#{@temp_dir}leaf.p12",
          destkeypass     => "abcdef123456",
          storetype       => 'pkcs12',
          password        => 'puppet',
          path            => #{@resource_path},
          source_password => 'pkcs12pass',
          source_alias    => 'Leaf Cert'
        }
      MANIFEST

      idempotent_apply(pp)
    end

    expectations = [
      %r{Alias name: leaf_cert},
      %r{Entry type: (keyEntry|PrivateKeyEntry)},
      %r{Certificate chain length: 3},
      %r{Serial number: 5},
      %r{Serial number: 4},
      %r{Serial number: 3},
    ]
    it 'verifies the private key and chain' do
      run_shell((keystore_list target), expect_failures: true) do |r|
        expect(r.exit_code).to eq(@exit_code)
        expectations.each do |expect|
          expect(r.stdout).to match(expect)
        end
      end
    end

    it 'verifies the private key password' do
      run_shell((keystore_list target) + ' -alias leaf_cert -keypass abcdef123456 -new pass1234', expect_failures: true) do |r|
        expect(r.exit_code).to eq(@exit_code)
      end
    end
  end # context 'with a destkeypass'
end
