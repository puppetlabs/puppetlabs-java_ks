require 'spec_helper_acceptance'

describe 'managing java keystores without a correct password', unless: UNSUPPORTED_PLATFORMS.include?(fact('operatingsystem')) do
  # rubocop:disable RSpec/InstanceVariable : Instance variables are inherited and thus cannot be contained within lets
  include_context 'common variables'
  target = "#{@target_dir}keystore_failed_password.ts"

  it 'creates a keystore' do
    pp_one = <<-MANIFEST
      java_ks { 'puppetca:keystore':
        ensure       => #{@ensure_ks},
        certificate  => "#{@temp_dir}ca.pem",
        target       => '#{target}',
        password     => 'coraline',
        trustcacerts => true,
        path         => #{@resource_path},
    }
    MANIFEST

    apply_manifest(pp_one, catch_failures: true)
  end

  expectations = [
    %r{Your keystore contains 1 entry},
    %r{Alias name: puppetca},
    %r{CN=Test CA},
  ]
  it 'verifies the keystore #zero' do
    shell("\"#{@keytool_path}keytool\" -list -v -keystore #{target} -storepass coraline") do |r|
      expect(r.exit_code).to be_zero
    end
  end
  it 'verifies the keytore #expected' do
    shell("\"#{@keytool_path}keytool\" -list -v -keystore #{target} -storepass coraline") do |r|
      expectations.each do |expect|
        expect(r.stdout).to match(expect)
      end
    end
  end

  it 'recreates a keystore if password fails' do
    pp_two = <<-MANIFEST

      java_ks { 'puppetca:keystore':
        ensure              => #{@ensure_ks},
        certificate         => "#{@temp_dir}ca.pem",
        target              => '#{target}',
        password            => 'bobinsky',
        password_fail_reset => true,
        trustcacerts        => true,
        path                => #{@resource_path},
    }
    MANIFEST

    apply_manifest(pp_two, catch_failures: true)
    apply_manifest(pp_two, catch_changes: true)
  end

  it 'verifies the keystore again #zero' do
    shell("\"#{@keytool_path}keytool\" -list -v -keystore #{target} -storepass bobinsky") do |r|
      expect(r.exit_code).to be_zero
    end
  end
  it 'verifies the keytore again #expected' do
    shell("\"#{@keytool_path}keytool\" -list -v -keystore #{target} -storepass bobinsky") do |r|
      expectations.each do |expect|
        expect(r.stdout).to match(expect)
      end
    end
  end
end
