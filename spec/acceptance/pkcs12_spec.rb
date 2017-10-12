require 'spec_helper_acceptance'

hostname = default.node_name

describe 'managing java pkcs12', :unless => UNSUPPORTED_PLATFORMS.include?(fact('operatingsystem')) do
  include_context 'common variables'
  case fact('osfamily')
    when 'windows'
      target = 'c:/pkcs12.ks'
    else
      target = '/etc/pkcs12.ks'
  end

  it 'creates a private key with chain' do
    pp = <<-EOS
      java_ks { 'Leaf Cert:#{target}':
        ensure          => #{@ensure_ks},
        certificate     => "#{@temp_dir}leaf.p12",
        storetype       => 'pkcs12',
        password        => 'puppet',
        path            => #{@resource_path},
        source_password => 'pkcs12pass'
      }
    EOS

    apply_manifest(pp, :catch_failures => true)
  end

  it 'verifies the private key and chain' do
    shell("#{@keytool_path}keytool -list -v -keystore #{target} -storepass puppet") do |r|
      expect(r.exit_code).to be_zero
      expect(r.stdout).to match(/Alias name: leaf cert/)
      expect(r.stdout).to match(/Entry type: (keyEntry|PrivateKeyEntry)/)
      expect(r.stdout).to match(/Certificate chain length: 3/)
      expect(r.stdout).to match(/^Serial number: 5$.*^Serial number: 4$.*^Serial number: 3$/m)
    end
  end
end
