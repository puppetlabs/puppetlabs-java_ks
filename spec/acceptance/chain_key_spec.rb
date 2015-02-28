require 'spec_helper_acceptance'

hostname = default.node_name
describe 'managing java chain keys', :unless => UNSUPPORTED_PLATFORMS.include?(fact('operatingsystem')) do
  include_context 'common variables'

  case fact('osfamily')
    when "windows"
      target = 'c:/chain_key.ks'
    else
      target = '/etc/chain_key.ks'
  end
  it 'creates a private key with chain certs' do
    pp = <<-EOS
      java_ks { 'broker.example.com:#{target}':
        ensure       => latest,
        certificate  => "#{@temp_dir}ca.pem",
        chain        => "#{@temp_dir}chain.pem",
        private_key  => "#{@temp_dir}privkey.pem",
        password     => 'puppet',
        path         => #{@resource_path},
      }
    EOS

    apply_manifest(pp, :catch_failures => true)
  end

  it 'verifies the private key' do
    shell("#{@keytool_path}keytool -list -v -keystore #{target} -storepass puppet") do |r|
      expect(r.exit_code).to be_zero
      expect(r.stdout).to match(/Alias name: broker\.example\.com/)
      expect(r.stdout).to match(/Entry type: (keyEntry|PrivateKeyEntry)/)
      expect(r.stdout).to match(/CN=Test CA/)
    end
  end
end

describe 'managing non existent java chain keys in noop', :unless => UNSUPPORTED_PLATFORMS.include?(fact('operatingsystem')) do
  include_context 'common variables'

  case fact('osfamily')
    when "windows"
      target = 'c:/noop_chain_key.ks'
      temp_dir = 'C:/tmp/'
    else
      target = '/etc/noop_chain_key.ks'
      temp_dir = '/tmp/'
  end
  it 'does not create a new keystore in noop' do
    pp = <<-EOS
      $filenames = ["#{temp_dir}noop_ca.pem",
                    "#{temp_dir}noop_chain.pem",
                    "#{temp_dir}noop_privkey.pem"]
      file { $filenames:
        ensure  => file,
        content => 'content',
      } ->
      java_ks { 'broker.example.com:#{target}':
        ensure       => latest,
        certificate  => "#{temp_dir}noop_ca.pem",
        chain        => "#{temp_dir}noop_chain.pem",
        private_key  => "#{temp_dir}noop_privkey.pem",
        password     => 'puppet',
        path         => #{@resource_path},
      }
    EOS

    # in noop mode, when the dependent certificate files are not present in the system,
    # java_ks will not invoke openssl to validate their status, thus noop will succeed
    apply_manifest(pp, :catch_failures => true, :noop => true)
  end

  # verifies the dependent files are missing
  ["#{temp_dir}noop_ca.pem", "#{temp_dir}noop_chain.pem", "#{temp_dir}noop_privkey.pem"].each do |filename|
    describe file("#{filename}") do
      it { should_not be_file }
    end
  end

  # verifies the keystore is not created
  describe file("#{target}") do
    it { should_not be_file }
  end
end

describe 'managing existing java chain keys in noop', :unless => UNSUPPORTED_PLATFORMS.include?(fact('operatingsystem')) do
  include_context 'common variables'

  case fact('osfamily')
    when "windows"
      target = 'c:/noop2_chain_key.ks'
    else
      target = '/etc/noop2_chain_key.ks'
  end
  it 'does not create a new keystore in noop' do
    pp = <<-EOS
      java_ks { 'broker.example.com:#{target}':
        ensure       => latest,
        certificate  => "#{@temp_dir}ca.pem",
        chain        => "#{@temp_dir}chain.pem",
        private_key  => "#{@temp_dir}privkey.pem",
        password     => 'puppet',
        path         => #{@resource_path},
      }
    EOS

    apply_manifest(pp, :catch_failures => true, :noop => true)
  end

  # in noop mode, when the dependent certificate files are present in the system,
  # java_ks will invoke openssl to validate their status, but will not create the keystore
  describe file("#{target}") do
    it { should_not be_file }
  end
end