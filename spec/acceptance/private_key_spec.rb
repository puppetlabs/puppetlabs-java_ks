require 'spec_helper_acceptance'

hostname = default.node_name

describe 'managing java private keys', :unless => UNSUPPORTED_PLATFORMS.include?(fact('operatingsystem')) do
  include_context 'common variables'
  case fact('osfamily')
    when 'windows'
      target = 'c:/private_key.ts'
    else
      target = '/etc/private_key.ts'
  end

  it 'creates a private key' do
    pp = <<-EOS
      java_ks { 'broker.example.com:#{target}':
        ensure       => #{@ensure_ks},
        certificate  => "#{@temp_dir}ca.pem",
        private_key  => "#{@temp_dir}privkey.pem",
        password     => 'puppet',
        path         => #{@resource_path},
      }
    EOS

    apply_manifest(pp, :catch_failures => true)
  end

  it 'verifies the private key' do
    shell("#{@keytool_path}keytool -list -v -keystore #{target} -storepass puppet") do |r|
      expect(r.exit_code).to be_zero
      expect(r.stdout).to match(/Alias name: broker\.example\.com/)
      expect(r.stdout).to match(/Entry type: (keyEntry|PrivateKeyEntry)/)
      expect(r.stdout).to match(/CN=Test CA/)
    end
  end
end
