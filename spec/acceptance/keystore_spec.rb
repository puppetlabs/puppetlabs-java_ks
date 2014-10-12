require 'spec_helper_acceptance'

describe 'managing java keystores', :unless => UNSUPPORTED_PLATFORMS.include?(fact('operatingsystem')) do
  opts = {:catch_failures => true}
  ensure_ks = 'latest'
  case fact('osfamily')
    when "Solaris"
      keytool_path = '/usr/java/bin/'
      resource_path = "['/usr/java/bin/','/opt/puppet/bin/','/usr/bin/']"
      target = '/etc/keystore.ks'
    when "AIX"
      keytool_path = '/usr/java6/bin/'
      resource_path = "['/usr/java6/bin/','/usr/bin/']"
      target = '/etc/keystore.ks'
    when 'windows'
      ensure_ks = 'present'
      keytool_path = 'C:/Java/jdk1.7.0_60/bin/'
      target = 'c:/keystore.ks'
      resource_path = "['C:/Java/jdk1.7.0_60/bin/']"
      opts[:environment] = {'PATH' => "%PATH%;#{keytool_path}"}
    else
      target = '/etc/keystore.ks'
      resource_path = "undef"
  end
  it 'creates a keystore' do
    pp = <<-EOS
      java_ks { 'puppetca:keystore':
        ensure       => #{ensure_ks},
        certificate  => "${settings::ssldir}/certs/ca.pem",
        target       => '#{target}',
        password     => 'puppet',
        trustcacerts => true,
        path         => #{resource_path},
      }
    EOS

    apply_manifest(pp, :catch_failures => true)
  end

  it 'verifies the keystore' do
    shell("#{keytool_path}keytool -list -v -keystore #{target} -storepass puppet") do |r|
      expect(r.exit_code).to be_zero
      expect(r.stdout).to match(/Your keystore contains 1 entry/)
      expect(r.stdout).to match(/Alias name: puppetca/)
      expect(r.stdout).to match(/CN=Puppet CA/)
    end
  end
end
