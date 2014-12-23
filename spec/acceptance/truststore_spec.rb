require 'spec_helper_acceptance'

describe 'managing java truststores', :unless => UNSUPPORTED_PLATFORMS.include?(fact('operatingsystem')) do
  include_context 'common variables'

  case fact('osfamily')
    when "windows"
      target = 'c:/truststore.ts'
    else
      target = '/etc/truststore.ts'
  end

  it 'creates a truststore' do
    pp = <<-EOS
      java_ks { 'puppetca:truststore':
        ensure       => #{@ensure_ks},
        certificate  => "#{@temp_dir}ca.pem",
        target       => '#{target}',
        password     => 'puppet',
        trustcacerts => true,
        path         => #{@resource_path},
    }
    EOS
    apply_manifest(pp, :catch_failures => true)
  end

  it 'verifies the truststore' do
    shell("#{@keytool_path}keytool -list -v -keystore #{target} -storepass puppet") do |r|
      expect(r.exit_code).to be_zero
      expect(r.stdout).to match(/Your keystore contains 1 entry/)
      expect(r.stdout).to match(/Alias name: puppetca/)
      expect(r.stdout).to match(/CN=Test CA/)
    end
  end
end
