require 'spec_helper_acceptance'

describe 'managing java keystores without a correct password', :unless => UNSUPPORTED_PLATFORMS.include?(fact('operatingsystem')) do
  include_context 'common variables'
  target = "#{@target_dir}keystore_failed_password.ts"

  it 'creates a keystore' do
    pp = <<-EOS
      java_ks { 'puppetca:keystore':
        ensure       => #{@ensure_ks},
        certificate  => "#{@temp_dir}ca.pem",
        target       => '#{target}',
        password     => 'coraline',
        trustcacerts => true,
        path         => #{@resource_path},
    }
    EOS
    apply_manifest(pp, :catch_failures => true)
  end

  it 'verifies the keystore' do
    shell("\"#{@keytool_path}keytool\" -list -v -keystore #{target} -storepass coraline") do |r|
      expect(r.exit_code).to be_zero
      expect(r.stdout).to match(/Your keystore contains 1 entry/)
      expect(r.stdout).to match(/Alias name: puppetca/)
      expect(r.stdout).to match(/CN=Test CA/)
    end
  end

  it 'recreates a keystore if password fails' do
    pp = <<-EOS
      java_ks { 'puppetca:keystore':
        ensure              => #{@ensure_ks},
        certificate         => "#{@temp_dir}ca.pem",
        target              => '#{target}',
        password            => 'bobinsky',
        password_fail_reset => true,
        trustcacerts        => true,
        path                => #{@resource_path},
    }
    EOS
    apply_manifest(pp, :catch_failures => true)
  end

  it 'verifies the keystore' do
    shell("\"#{@keytool_path}keytool\" -list -v -keystore #{target} -storepass bobinsky") do |r|
      expect(r.exit_code).to be_zero
      expect(r.stdout).to match(/Your keystore contains 1 entry/)
      expect(r.stdout).to match(/Alias name: puppetca/)
      expect(r.stdout).to match(/CN=Test CA/)
    end
  end
end
