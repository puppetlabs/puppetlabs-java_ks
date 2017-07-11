require 'spec_helper_acceptance'

describe 'unsupported distributions and OSes', :if => UNSUPPORTED_PLATFORMS.include?(fact('operatingsystem')) do
  include_context 'common variables'
  it 'should fail' do
    pp = <<-EOS
    java_ks { 'puppetca:keystore':
      ensure       => latest,
      certificate  => "#{@temp_dir}ca.pem",
      target       => "#{@target_dir}unsupported.ks",
      password     => 'puppet',
      trustcacerts => true,
      path         => #{@resource_path},
    }
    EOS
    expect(apply_manifest(pp, :expect_failures => true).stderr).to match(/unsupported os/)
  end
end
