require 'spec_helper_acceptance'

# SLES by default does not support this form of encyrption.
describe 'managing java pkcs12', unless: (UNSUPPORTED_PLATFORMS.include?(fact('operatingsystem')) || fact('operatingsystem') == 'SLES') do
  # rubocop:disable RSpec/InstanceVariable : Instance variables are inherited and thus cannot be contained within lets
  include_context 'common variables'
  context 'with defaults' do
    target = case fact('osfamily')
             when 'windows'
               'c:/pkcs12.ks'
             else
               '/etc/pkcs12.ks'
             end

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

      apply_manifest(pp, catch_failures: true)
      apply_manifest(pp, catch_changes: true)
    end

    expectations = [
      %r{Alias name: leaf cert},
      %r{Entry type: (keyEntry|PrivateKeyEntry)},
      %r{Certificate chain length: 3},
      %r{^Serial number: 5$.*^Serial number: 4$.*^Serial number: 3$}m,
    ]
    it 'verifies the private key and chain #zero' do
      shell("\"#{@keytool_path}keytool\" -list -v -keystore #{target} -storepass puppet") do |r|
        expect(r.exit_code).to be_zero
      end
    end
    it 'verifies the private key and chain #expected' do
      shell("\"#{@keytool_path}keytool\" -list -v -keystore #{target} -storepass puppet") do |r|
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

      apply_manifest(pp, catch_failures: true)
      apply_manifest(pp, catch_changes: true)

      expectations = if fact('osfamily') == 'windows'
                       [
                         %r{Alias name: leaf cert},
                         %r{Entry type: (keyEntry|PrivateKeyEntry)},
                         %r{Certificate chain length: 3},
                         %r{^Serial number: 3$}m,
                         %r{^Serial number: 4$}m,
                         %r{^Serial number: 5$}m,
                       ]
                     else
                       [
                         %r{Alias name: leaf cert},
                         %r{Entry type: (keyEntry|PrivateKeyEntry)},
                         %r{Certificate chain length: 2},
                         %r{^Serial number: 5$.*^Serial number: 6$}m,
                       ]
                     end
      shell("\"#{@keytool_path}keytool\" -list -v -keystore #{target} -storepass puppet") do |r|
        expect(r.exit_code).to be_zero
      end
      shell("\"#{@keytool_path}keytool\" -list -v -keystore #{target} -storepass puppet") do |r|
        expectations.each do |expect|
          expect(r.stdout).to match(expect)
        end
      end
    end
  end # context 'with defaults'

  context 'with a different alias' do
    target = case fact('osfamily')
             when 'windows'
               'c:/pkcs12-2.ks'
             else
               '/etc/pkcs12-2.ks'
             end

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

      apply_manifest(pp, catch_failures: true)
      apply_manifest(pp, catch_changes: true)
    end

    expectations = [
      %r{Alias name: leaf_cert},
      %r{Entry type: (keyEntry|PrivateKeyEntry)},
      %r{Certificate chain length: 3},
      %r{^Serial number: 5$.*^Serial number: 4$.*^Serial number: 3$}m,
    ]
    it 'verifies the private key and chain #zero' do
      shell("\"#{@keytool_path}keytool\" -list -v -keystore #{target} -storepass puppet") do |r|
        expect(r.exit_code).to be_zero
      end
    end
    it 'verifies the private key and chain #expected' do
      shell("\"#{@keytool_path}keytool\" -list -v -keystore #{target} -storepass puppet") do |r|
        expectations.each do |expect|
          expect(r.stdout).to match(expect)
        end
      end
    end
  end # context 'with a different alias'

  context 'with a destkeypass' do
    target = case fact('osfamily')
             when 'windows'
               'c:/pkcs12-3.ks'
             else
               '/etc/pkcs12-3.ks'
             end

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

      apply_manifest(pp, catch_failures: true)
      apply_manifest(pp, catch_changes: true)
    end

    expectations = [
      %r{Alias name: leaf_cert},
      %r{Entry type: (keyEntry|PrivateKeyEntry)},
      %r{Certificate chain length: 3},
      %r{^Serial number: 5$.*^Serial number: 4$.*^Serial number: 3$}m,
    ]
    it 'verifies the private key and chain #zero' do
      shell("\"#{@keytool_path}keytool\" -list -v -keystore #{target} -storepass puppet") do |r|
        expect(r.exit_code).to be_zero
      end
    end
    it 'verifies the private key and chain #expected' do
      shell("\"#{@keytool_path}keytool\" -list -v -keystore #{target} -storepass puppet") do |r|
        expectations.each do |expect|
          expect(r.stdout).to match(expect)
        end
      end
    end
    # -keypasswd commands not supported if -storetype is PKCS12 on ubuntu 18.04 with current java version
    unless fact('operatingsystemmajrelease') == '18.04'
      it 'verifies the private key password' do
        shell("\"#{@keytool_path}keytool\" -keypasswd -keystore #{target} -storepass puppet -alias leaf_cert -keypass abcdef123456 -new pass1234") do |r|
          expect(r.exit_code).to be_zero
        end
      end
    end
  end # context 'with a destkeypass'
end
