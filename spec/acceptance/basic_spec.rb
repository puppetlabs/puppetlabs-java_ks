require 'spec_helper_acceptance'

describe 'prep nodes', :unless => UNSUPPORTED_PLATFORMS.include?(fact('operatingsystem')) do
  it 'requires java', :unless => ["Solaris","AIX"].include?(fact('osfamily')) do
    pp = <<-EOS
      class { 'java': }
    EOS

    apply_manifest(pp, :catch_failures => true)
  end
end
