require 'spec_helper_acceptance'

describe 'managing java truststores', unless: UNSUPPORTED_PLATFORMS.include?(fact('operatingsystem')) do
  # rubocop:disable RSpec/InstanceVariable : Instance variables are inherited and thus cannot be contained within lets
  include_context 'common variables'
  target = "#{@target_dir}truststore.ts"

  it 'creates a truststore' do
    pp = <<-EOS
      java_ks { 'puppetca:truststore':
        ensure       => #{@ensure_ks},
        certificate  => "#{@temp_dir}ca.pem",
        target       => "#{target}",
        password     => 'puppet',
        trustcacerts => true,
        path         => #{@resource_path},
    }
    EOS
    apply_manifest(pp, catch_failures: true)
    apply_manifest(pp, catch_changes: true)
  end

  expectations = [
    %r{Your keystore contains 1 entry},
    %r{Alias name: puppetca},
    %r{CN=Test CA},
  ]
  it 'verifies the truststore #zero' do
    shell("\"#{@keytool_path}keytool\" -list -v -keystore #{target} -storepass puppet") do |r|
      expect(r.exit_code).to be_zero
    end
  end
  it 'verifies the truststore #expected' do
    shell("\"#{@keytool_path}keytool\" -list -v -keystore #{target} -storepass puppet") do |r|
      expectations.each do |expect|
        expect(r.stdout).to match(expect)
      end
    end
  end
end
