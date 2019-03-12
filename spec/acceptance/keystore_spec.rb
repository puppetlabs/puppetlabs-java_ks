require 'spec_helper_acceptance'

describe 'managing java keystores', unless: UNSUPPORTED_PLATFORMS.include?(host_inventory['facter']['os']['name']) do
  # rubocop:disable RSpec/InstanceVariable : Instance variables are inherited and thus cannot be contained within lets
  include_context 'common variables'
  target = "#{@target_dir}keystore.ks"

  describe 'basic tests' do
    it 'creates a keystore' do
      pp_one = <<-MANIFEST
        java_ks { 'puppetca:keystore':
          ensure       => latest,
          certificate  => "#{@temp_dir}ca.pem",
          target       => '#{target}',
          password     => 'puppet',
          trustcacerts => true,
          path         => #{@resource_path},
        }
      MANIFEST

      idempotent_apply(default, pp_one)
    end

    expectations = [
      %r{Your keystore contains 1 entry},
      %r{Alias name: puppetca},
      %r{CN=Test CA},
    ]
    it 'verifies the keystore #zero' do
      shell("\"#{@keytool_path}keytool\" -list -v -keystore #{target} -storepass puppet") do |r|
        expect(r.exit_code).to be_zero
      end
    end
    it 'verifies the keytore #expected' do
      shell("\"#{@keytool_path}keytool\" -list -v -keystore #{target} -storepass puppet") do |r|
        expectations.each do |expect|
          expect(r.stdout).to match(expect)
        end
      end
    end

    it 'uses password_file' do
      pp_two = <<-MANIFEST
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
      MANIFEST

      idempotent_apply(default, pp_two)
    end
  end

  unless os[:family] == 'debian' && os[:release].start_with?('18.04')
    describe 'storetype' do
      it 'creates a keystore' do
        pp = <<-MANIFEST
          java_ks { 'puppetca:keystore':
            ensure       => latest,
            certificate  => "#{@temp_dir}ca.pem",
            target       => '#{target}',
            password     => 'puppet',
            trustcacerts => true,
            path         => #{@resource_path},
            storetype    => 'jceks',
          }
        MANIFEST

        idempotent_apply(default, pp)
      end

      expectations = [
        %r{Your keystore contains 2 entries},
        %r{Alias name: puppetca},
        %r{CN=Test CA},
      ]
      it 'verifies the keystore #zero' do
        shell("\"#{@keytool_path}keytool\" -list -v -keystore #{target} -storepass puppet") do |r|
          expect(r.exit_code).to be_zero
        end
      end
      it 'verifies the keytore #expected' do
        shell("\"#{@keytool_path}keytool\" -list -v -keystore #{target} -storepass puppet") do |r|
          expectations.each do |expect|
            expect(r.stdout).to match(expect)
          end
        end
      end
    end
  end
end
