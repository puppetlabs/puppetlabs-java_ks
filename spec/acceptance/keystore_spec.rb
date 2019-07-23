require 'spec_helper_acceptance'

# rubocop:disable RSpec/InstanceVariable : Instance variables are inherited and thus cannot be contained within lets

describe 'managing java keystores', unless: UNSUPPORTED_PLATFORMS.include?(os[:family]) do
  def keystore_command(target, password = 'puppet')
    command = "\"#{@keytool_path}keytool\" -list -v -keystore #{target} -storepass #{password}"
    command.prepend('& ') if os[:family] == 'windows'
    command
  end

  include_context 'common variables'

  let(:target) { "#{@target_dir}keystore.ks" }

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

      idempotent_apply(pp_one)
    end

    describe 'verifies' do
      expectations = [
        %r{Your keystore contains 1 entry},
        %r{Alias name: puppetca},
        %r{CN=Test CA},
      ]
      it 'the keystore' do
        run_shell((keystore_command target), expect_failures: true) do |r|
          expectations.each do |expect|
            expect(r.stdout).to match(expect)
          end
        end
      end

      it 'uses a password_file' do
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

        idempotent_apply(pp_two)
      end

      it 'recreates a keystore if password fails' do
        pp_three = <<-MANIFEST

          java_ks { 'puppetca:keystore':
            ensure              => latest,
            certificate         => "#{@temp_dir}ca.pem",
            target              => '#{target}',
            password            => 'pepput',
            password_fail_reset => true,
            trustcacerts        => true,
            path                => #{@resource_path},
        }
        MANIFEST

        idempotent_apply(pp_three)
      end

      it 'verifies the keystore again' do
        run_shell(keystore_command(target, 'pepput'), expect_failures: true) do |r|
          expectations.each do |expect|
            expect(r.stdout).to match(expect)
          end
        end
      end

      it 'cleans up the test artifacts' do
        run_shell("rm #{target}") do |r|
          expect(r.exit_code).to be_zero
        end
      end
    end
  end

  if os[:family] == 'ubuntu' && !os[:release].start_with?('18.04')
    describe 'storetype' do
      let(:target) { "#{@target_dir}storetypekeystore.ks" }

      it 'creates a keystore' do
        skip 'MODULES-9446'
        pp = <<-MANIFEST
          java_ks { 'puppetca:keystore':
            ensure       => latest,
            certificate  => "#{@temp_dir}ca.pem",
            target       => '#{target}',
            password     => 'pepput',
            trustcacerts => true,
            path         => #{@resource_path},
            storetype    => 'jceks',
          }
        MANIFEST

        idempotent_apply(pp)
      end

      expectations = [
        %r{Your keystore contains 1 entry},
        %r{Alias name: puppetca},
        %r{CN=Test CA},
      ]
      it 'verifies the keytore' do
        skip 'MODULES-9446'
        run_shell((keystore_command(target, 'pepput') + ' -storetype jceks'), expect_failures: true) do |r|
          expectations.each do |expect|
            expect(r.stdout).to match(expect)
          end
        end
      end
    end
  end
end
