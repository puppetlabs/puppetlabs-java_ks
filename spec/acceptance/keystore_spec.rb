require 'spec_helper_acceptance'

describe 'managing java keystores', :unless => UNSUPPORTED_PLATFORMS.include?(fact('operatingsystem')) do
  include_context 'common variables'

  case fact('osfamily')
    when 'windows'
      target = 'c:/tmp/keystore.ks'
    else
      target = '/etc/keystore.ks'
  end

  describe 'basic tests' do
    it 'should create a keystore' do
      pp = <<-EOS
        java_ks { 'puppetca:keystore':
          ensure       => latest,
          certificate  => "#{@temp_dir}ca.pem",
          target       => '#{target}',
          password     => 'puppet',
          trustcacerts => true,
          path         => #{@resource_path},
        }
      EOS

      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end

    it 'verifies the keystore' do
      shell("#{@keytool_path}keytool -list -v -keystore #{target} -storepass puppet") do |r|
        expect(r.exit_code).to be_zero
        expect(r.stdout).to match(/Your keystore contains 1 entry/)
        expect(r.stdout).to match(/Alias name: puppetca/)
        expect(r.stdout).to match(/CN=Test CA/)
      end
    end

    it 'uses password_file' do
      pp = <<-EOS
        file { '#{@temp_dir}password':
          ensure  => file,
          content => 'puppet',
        }
        java_ks { 'puppetca2:keystore':
          ensure        => latest,
          certificate   => "#{@temp_dir}ca2.pem",
          target        => '#{target}',
          password_file => '#{@temp_dir}password',
          trustcacerts  => true,
          path          => #{@resource_path},
          require       => File['#{@temp_dir}password']
        }
      EOS

      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end
  end

  describe 'storetype' do
    it 'should create a keystore' do
      pp = <<-EOS
        java_ks { 'puppetca:keystore':
          ensure       => latest,
          certificate  => "#{@temp_dir}ca.pem",
          target       => '#{target}',
          password     => 'puppet',
          trustcacerts => true,
          path         => #{@resource_path},
          storetype    => 'jceks',
        }
      EOS

      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end

    it 'verifies the keystore' do
      shell("#{@keytool_path}keytool -list -v -keystore #{target} -storepass puppet") do |r|
        expect(r.exit_code).to be_zero
        expect(r.stdout).to match(/Your keystore contains 2 entries/)
        expect(r.stdout).to match(/Alias name: puppetca/)
        expect(r.stdout).to match(/CN=Test CA/)
      end
    end
  end

end
