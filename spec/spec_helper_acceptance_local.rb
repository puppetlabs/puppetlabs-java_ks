require_relative 'support/functions/cert_functions'

UNSUPPORTED_PLATFORMS = [].freeze

def keystore_command
  # The @keytool global does not exist right now as the function is defined.
  # When the tests call the function, RSpec.shared_context below will have run
  # by then and the variable will exist.
  command = "\"#{@keytool_path}keytool\""
  command.prepend('& ') if os[:family] == 'windows'
  command
end

def keystore_list(target, pass = 'puppet', storetype = nil)
  command = "#{keystore_command} -list -v -keystore #{target} -storepass #{pass}"
  command << " -storetype #{storetype}" unless storetype.nil?
  command
end

def keystore_certreq(target, storepass = 'testpass', keypass = 'testkeypass', alias_url = 'broker.example.com')
  "#{keystore_command} -certreq -alias #{alias_url} -v " \
  "-keystore #{target} -storepass #{storepass} -keypass #{keypass}"
end

RSpec.configure do |c|
  # Readable test descriptions
  c.formatter = :documentation

  # Configure all nodes in nodeset
  c.before :suite do
    # Install module and dependencies
    copy_certs_to_sut
    # install java if windows
    if os[:family] =~ %r{windows}i
      run_shell('puppet module install puppetlabs-chocolatey')
      pp_one = <<-MANIFEST
        include chocolatey
        package { 'jdk8':
        ensure   => '8.0.211',
        provider => 'chocolatey'
        }
      MANIFEST
      # The Chocolatey module returns warning in it's output that fail the call
      # to apply_manifest if we don't expect failures.
      apply_manifest(pp_one, expect_failures: true)
    else
      run_shell('puppet module install puppetlabs-java')
      pp_two = <<-MANIFEST
        class { 'java': }
      MANIFEST
      # rubocop:enable Layout/IndentHeredoc : Indent must be as it is
      apply_manifest(pp_two)
    end
  end
end

RSpec.shared_context 'common variables' do
  before(:each) do
    java_major, java_minor = (ENV['JAVA_VERSION'] || '8u211').split('u')
    @ensure_ks = 'latest'
    @resource_path = 'undef'
    @target_dir = '/etc/'
    @temp_dir = '/tmp/'
    @exit_code = 0
    @remove_command = 'rm'
    case os[:family]
    when 'solaris'
      @keytool_path = '/usr/java/bin/'
      @resource_path = "['/usr/java/bin/','/opt/puppet/bin/']"
    when 'aix'
      @keytool_path = '/usr/java6/bin/'
      @resource_path = "['/usr/java6/bin/','/usr/bin/']"
    when 'windows'
      @ensure_ks = 'present'
      @keytool_path = "C:/Program Files/Java/jdk1.#{java_major}.0_#{java_minor}/bin/"
      @resource_path = "['C:/Program\ Files/Java/jdk1.#{java_major}.0_#{java_minor}/bin/']"
      @target_dir = 'c:/'
      @temp_dir = 'C:/tmp/'
      @exit_code = 1
      @remove_command = 'del'
    end
  end
end
