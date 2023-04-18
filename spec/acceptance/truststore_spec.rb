# frozen_string_literal: true

require 'spec_helper_acceptance'

describe 'managing java truststores' do
  # rubocop:disable RSpec/InstanceVariable : Instance variables are inherited and thus cannot be contained within lets
  include_context 'common variables'

  it 'creates a truststore' do
    command = "rm #{@temp_dir}truststore.ts"
    command = interpolate_powershell(command) if os[:family] == 'windows'
    run_shell(command, expect_failures: true)
    pp = <<-EOS
      java_ks { 'puppetca:#{@temp_dir}truststore':
        ensure       => #{@ensure_ks},
        certificate  => "#{@temp_dir}ca.pem",
        target       => "#{@temp_dir}truststore.ts",
        password     => 'puppet',
        trustcacerts => true,
        path         => #{@resource_path},
    }
    EOS
    idempotent_apply(pp)
  end

  expectations = [
    %r{Your keystore contains 1 entry},
    %r{Alias name: puppetca},
    %r{CN=Test CA},
  ]
  it 'verifies the truststore' do
    run_shell(keytool_command("-list -v -keystore #{@temp_dir}truststore.ts -storepass puppet")) do |r|
      expect(r.exit_code).to be_zero
      expectations.each do |expect|
        expect(r.stdout).to match(expect)
      end
    end
  end

  it 'recreates a truststore if password fails' do
    pp = <<-MANIFEST
      java_ks { 'puppetca:#{@temp_dir}truststore':
        ensure              => latest,
        certificate         => "#{@temp_dir}ca.pem",
        target              => "#{@temp_dir}truststore.ts",
        password            => 'bobinsky',
        password_fail_reset => true,
        trustcacerts        => true,
        path                => #{@resource_path},
    }
    MANIFEST
    idempotent_apply(pp)
  end

  it 'verifies the truststore again' do
    run_shell(keytool_command("-list -v -keystore #{@temp_dir}truststore.ts -storepass bobinsky")) do |r|
      expect(r.exit_code).to be_zero
      expectations.each do |expect|
        expect(r.stdout).to match(expect)
      end
    end
  end
  # rubocop:enable RSpec/InstanceVariable
end
