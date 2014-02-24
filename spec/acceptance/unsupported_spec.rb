require 'spec_helper_acceptance'

describe 'unsupported distributions and OSes', :if => UNSUPPORTED_PLATFORMS.include?(fact('operatingsystem')) do
  it 'should fail' do
    pp = <<-EOS
    class { 'java': }
    java_ks { 'puppetca:keystore':
      ensure       => latest,
      certificate  => '#{default['puppetpath']}/ssl/certs/ca.pem',
      target       => '/etc/keystore.ks',
      password     => 'puppet',
      trustcacerts => true,
    }
    EOS
    expect(apply_manifest(pp, :expect_failures => true).stderr).to match(/unsupported os/)
  end
end
