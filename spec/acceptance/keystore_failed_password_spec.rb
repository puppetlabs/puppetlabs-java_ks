require 'spec_helper_acceptance'

describe 'managing java keystores without a correct password', :unless => UNSUPPORTED_PLATFORMS.include?(fact('operatingsystem')) do
  case fact('osfamily')
  when "Solaris"
    keytool_path = '/usr/java/bin/'
    resource_path = "['/usr/java/bin/','/opt/puppet/bin/']"
  when "AIX"
    keytool_path = '/usr/java6/bin/'
    resource_path = "['/usr/java6/bin/','/usr/bin/']"
  else
    resource_path = "undef"
  end
  it 'creates a keystore' do
    pp = <<-EOS
      java_ks { 'puppetca:keystore':
        ensure       => latest,
        certificate  => "/tmp/ca.pem",
        target       => '/etc/keystore_failed_password.ts',
        password     => 'coraline',
        trustcacerts => true,
        path         => #{resource_path},
    }
    EOS
    apply_manifest(pp, :catch_failures => true)
  end

  it 'verifies the keystore' do
    shell("#{keytool_path}keytool -list -v -keystore /etc/keystore_failed_password.ts -storepass coraline") do |r|
      expect(r.exit_code).to be_zero
      expect(r.stdout).to match(/Your keystore contains 1 entry/)
      expect(r.stdout).to match(/Alias name: puppetca/)
      expect(r.stdout).to match(/CN=Test CA/)
    end
  end

  it 'recreates a keystore if password fails' do
    pp = <<-EOS
      java_ks { 'puppetca:keystore':
        ensure              => latest,
        certificate         => "/tmp/ca.pem",
        target              => '/etc/keystore_failed_password.ts',
        password            => 'bobinsky',
        password_fail_reset => true,
        trustcacerts        => true,
        path                => #{resource_path},
    }
    EOS
    apply_manifest(pp, :catch_failures => true)
  end

  it 'verifies the keystore' do
    shell("#{keytool_path}keytool -list -v -keystore /etc/keystore_failed_password.ts -storepass bobinsky") do |r|
      expect(r.exit_code).to be_zero
      expect(r.stdout).to match(/Your keystore contains 1 entry/)
      expect(r.stdout).to match(/Alias name: puppetca/)
      expect(r.stdout).to match(/CN=Test CA/)
    end
  end
end
