require 'spec_helper_acceptance'

# rubocop:disable RSpec/InstanceVariable : Instance variables are inherited and thus cannot be contained within lets

describe 'managing java truststores', unless: UNSUPPORTED_PLATFORMS.include?(os[:family]) do
  let(:target) { "#{@target_dir}truststore.ts" }

  include_context 'common variables'

  it 'ensures the working directory is clean' do
    run_shell("#{@remove_command} #{target}", expect_failures: true)
  end

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
    idempotent_apply(pp)
  end

  expectations = [
    %r{Your keystore contains 1 entry},
    %r{Alias name: puppetca},
    %r{CN=Test CA},
  ]
  it 'verifies the truststore' do
    run_shell((keystore_list target), expect_failures: true) do |r|
      expect(r.exit_code).to be_zero
      expectations.each do |expect|
        expect(r.stdout).to match(expect)
      end
    end
  end

  it 'recreates a truststore if password fails' do
    pp = <<-MANIFEST
      java_ks { 'puppetca:truststore':
        ensure              => latest,
        certificate         => "#{@temp_dir}ca.pem",
        target              => "#{target}",
        password            => 'bobinsky',
        password_fail_reset => true,
        trustcacerts        => true,
        path                => #{@resource_path},
    }
    MANIFEST
    idempotent_apply(pp)
  end

  it 'verifies the truststore again' do
    run_shell(keystore_list(target, 'bobinsky'), expect_failures: true) do |r|
      expect(r.exit_code).to be_zero
      expectations.each do |expect|
        expect(r.stdout).to match(expect)
      end
    end
  end
end
