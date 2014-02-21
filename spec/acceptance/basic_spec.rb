require 'spec_helper_acceptance'

describe 'prep nodes', :unless => UNSUPPORTED_PLATFORMS.include?(fact('osfamily')) do
  it 'requires java' do
    pp = <<-EOS
      class { 'java': }
    EOS

    apply_manifest(pp, :catch_failures => true)
  end
end
