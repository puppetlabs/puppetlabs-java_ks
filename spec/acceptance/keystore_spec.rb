require 'spec_helper_acceptance'

describe 'managing java keystores' do
  it 'creates a keystore' do
    pp = <<-EOS
      class { 'java': }
      java_ks { 'puppetca:keystore':
        ensure       => latest,
        certificate  => '/etc/puppet/ssl/certs/ca.pem',
        target       => '/etc/keystore.ks',
        password     => 'puppet',
        trustcacerts => true,
      }
    EOS

    apply_manifest(pp, :catch_failures => true)
  end

  it 'verifies the keystore' do
    shell('keytool -list -v -keystore /etc/keystore.ks -storepass puppet') do |r|
      expect(r.exit_code).to be_zero
      expect(r.stdout).to match(/Your keystore contains 1 entry/)
      expect(r.stdout).to match(/Alias name: puppetca/)
      expect(r.stdout).to match(/CN=Puppet CA/)
    end
  end
end
