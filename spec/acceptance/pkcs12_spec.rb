# frozen_string_literal: true

require 'spec_helper_acceptance'

# SLES by default does not support this form of encyrption.
describe 'managing java pkcs12', unless: (os[:family] == 'sles' || (os[:family] == 'debian' && os[:release].start_with?('10')) || (os[:family] == 'ubuntu' && os[:release].start_with?('18'))) do
  # rubocop:disable RSpec/InstanceVariable : Instance variables are inherited and thus cannot be contained within lets
  include_context 'with common variables'
  context 'with defaults' do
    it 'creates a private key with chain' do
      pp = <<-MANIFEST
        java_ks { 'Leaf Cert:#{@temp_dir}pkcs12.ks':
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
      %r{^Serial number: 5.*^Serial number: 4.*^Serial number: 3}m,
    ]
    it 'verifies the private key and chain' do
      run_shell(keytool_command("-list -v -keystore #{@temp_dir}pkcs12.ks -storepass puppet"), expect_failures: true) do |r|
        expectations.each do |expect|
          expect(r.stdout).to match(expect)
        end
      end
    end

    it 'updates the chain' do
      pp = <<-MANIFEST
        java_ks { 'Leaf Cert:#{@temp_dir}pkcs12.ks':
            ensure          => #{@ensure_ks},
            certificate     => "#{@temp_dir}leaf2.p12",
            storetype       => 'pkcs12',
            password        => 'puppet',
            path            => #{@resource_path},
            source_password => 'pkcs12pass'
        }
      MANIFEST

      idempotent_apply(pp)

      expectations = if os[:family] == 'windows' || (os[:family] == 'ubuntu' && ['20.04', '22.04'].include?(os[:release])) ||
                        (os[:family] == 'debian' && os[:release] =~ %r{^11|12})
                       [
                         %r{Alias name: leaf cert},
                         %r{Entry type: (keyEntry|PrivateKeyEntry)},
                         %r{Certificate chain length: 3},
                         %r{^Serial number: 3}m,
                         %r{^Serial number: 4}m,
                         %r{^Serial number: 5}m,
                       ]
                     else
                       [
                         %r{Alias name: leaf cert},
                         %r{Entry type: (keyEntry|PrivateKeyEntry)},
                         %r{Certificate chain length: 2},
                         %r{^Serial number: 5$.*^Serial number: 6$}m,
                       ]
                     end
      run_shell(keytool_command("-list -v -keystore #{@temp_dir}pkcs12.ks -storepass puppet"), expect_failures: true) do |r|
        expectations.each do |expect|
          expect(r.stdout).to match(expect)
        end
      end
    end
  end

  context 'with a different alias' do
    it 'creates a private key with chain' do
      pp = <<-MANIFEST
        java_ks { 'Leaf_Cert:#{@temp_dir}pkcs12.ks':
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
      %r{^Serial number: 5.*^Serial number: 4.*^Serial number: 3}m,
    ]
    it 'verifies the private key and chain' do
      run_shell(keytool_command("-list -v -keystore #{@temp_dir}pkcs12.ks -storepass puppet"), expect_failures: true) do |r|
        expectations.each do |expect|
          expect(r.stdout).to match(expect)
        end
      end
    end
  end

  context 'with a destkeypass' do
    command = if os[:family] == 'windows'
                interpolate_powershell("rm -force #{@temp_dir}pkcs12.ks")
              else
                "rm -f #{@temp_dir}pkcs12.ks"
              end
    before(:all) { run_shell(command, expect_failures: true) }

    it 'creates a private key with chain' do
      pp = <<-MANIFEST
        java_ks { 'Leaf_Cert:#{@temp_dir}/pkcs12.ks':
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
      %r{^Serial number: 5.*^Serial number: 4.*^Serial number: 3}m,
    ]
    it 'verifies the private key and chain' do
      run_shell(keytool_command("-list -v -keystore #{@temp_dir}pkcs12.ks -storepass puppet"), expect_failures: true) do |r|
        expectations.each do |expect|
          expect(r.stdout).to match(expect)
        end
      end
    end
  end
  # rubocop:enable RSpec/InstanceVariable
end
