# frozen_string_literal: true

require 'spec_helper_acceptance'

describe 'managing java keystores' do
  # rubocop:disable RSpec/InstanceVariable : Instance variables are inherited and thus cannot be contained within lets
  include_context 'common variables'

  describe 'basic tests' do
    it 'creates a keystore' do
      command = "rm #{@temp_dir}keystore.ks"
      command = interpolate_powershell(command) if os[:family] == 'windows'
      run_shell(command, expect_failures: true)
      pp_one = <<-MANIFEST
        java_ks { 'puppetca:keystore':
          ensure       => latest,
          certificate  => "#{@temp_dir}ca.pem",
          target       => '#{@temp_dir}keystore.ks',
          password     => 'puppet',
          trustcacerts => true,
          path         => #{@resource_path},
        }
      MANIFEST

      idempotent_apply(pp_one)
    end

    expectations = [
      %r{Your keystore contains 1 entry},
      %r{Alias name: puppetca},
      %r{CN=Test CA},
    ]
    it 'verifies the keytore' do
      run_shell(keytool_command("-list -v -keystore #{@temp_dir}keystore.ks -storepass puppet")) do |r|
        expect(r.exit_code).to be_zero
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
          target        => '#{@temp_dir}keystore.ks',
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

        java_ks { 'puppetca:#{@temp_dir}keystore':
          ensure              => latest,
          certificate         => "#{@temp_dir}ca.pem",
          target              => '#{@temp_dir}keystore.ks',
          password            => 'pepput',
          password_fail_reset => true,
          trustcacerts        => true,
          path                => #{@resource_path},
      }
      MANIFEST

      idempotent_apply(pp_three)
    end

    it 'verifies the keystore again' do
      run_shell(keytool_command("-list -v -keystore #{@temp_dir}keystore.ks -storepass pepput")) do |r|
        expect(r.exit_code).to be_zero
        expectations.each do |expect|
          expect(r.stdout).to match(expect)
        end
      end
    end
  end

  unless os[:family] == 'ubuntu' && os[:release].start_with?('18.04')
    describe 'storetype' do
      it 'creates a keystore' do
        pp = <<-MANIFEST
          java_ks { 'puppetca:#{@temp_dir}keystore':
            ensure       => latest,
            certificate  => "#{@temp_dir}ca.pem",
            target       => '#{@temp_dir}keystore.ks',
            password     => 'pepput',
            trustcacerts => true,
            path         => #{@resource_path},
            storetype    => 'jks',
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
        run_shell(keytool_command("-list -v -keystore #{@temp_dir}keystore.ks -storepass pepput")) do |r|
          expect(r.exit_code).to be_zero
          expectations.each do |expect|
            expect(r.stdout).to match(expect)
          end
        end
      end
    end
  end

  describe 'with der certificates' do
    it 'creates a keystore' do
      command = "rm #{@temp_dir}keystore.ks"
      command = interpolate_powershell(command) if os[:family] == 'windows'
      run_shell(command, expect_failures: true)
      pp_one = <<-MANIFEST
        java_ks { 'puppetcader:keystore':
          ensure       => latest,
          certificate  => "#{@temp_dir}ca.der",
          target       => '#{@temp_dir}keystore.ks',
          password     => 'puppet',
          trustcacerts => true,
          path         => #{@resource_path},
        }
      MANIFEST

      idempotent_apply(pp_one)
    end

    it 'adds a certificate and key' do
      pp_two = <<-MANIFEST
        java_ks { 'puppetcader_privkey:keystore':
          ensure       => latest,
          certificate  => "#{@temp_dir}ca.der",
          private_key  => "#{@temp_dir}privkey.pem",
          target       => '#{@temp_dir}keystore.ks',
          password     => 'puppet',
          trustcacerts => true,
          path         => #{@resource_path},
        }
      MANIFEST

      idempotent_apply(pp_two)
    end

    expectations = [
      %r{Your keystore contains 2 entries},
      %r{Alias name: puppetcader},
      %r{Alias name: puppetcader_privkey},
      %r{CN=Test CA},
    ]

    context 'when running on Linux', unless: os[:family] == 'windows' do
      it 'verifies the keystore' do
        run_shell(keytool_command("-list -v -keystore #{@temp_dir}keystore.ks -storepass puppet")) do |r|
          expect(r.exit_code).to be_zero
          expectations.each do |expect|
            expect(r.stdout).to match(expect)
          end
        end
      end
    end

    # On Windows, the keystore command warns about using a proprietary format when using DER formatted certs. We should
    # not take this as a failure, but also, we should also not blindly ignore all STDERR from the result either. If we
    # get an exit code of 1, we'll check to see if the STDERR message was the cert format warning and still pass the
    # test. We will still catch any errors that occur and are not related
    context 'when running on Windows', if: os[:family] == 'windows' do
      it 'verifies the keystore' do
        run_shell(keytool_command("-list -v -keystore #{@temp_dir}keystore.ks -storepass puppet"), expect_failures: true) do |r|
          expect(r.exit_code).to be_between(0, 1)
          expectations.each do |expect|
            expect(r.stdout).to match(expect)
          end
          # Pattern below ensures that it's the only warning printed out by anchoring to the end of line ($). This is to
          # handle the case that multiple warnings should ever occur - a looser match could potentially hide additional
          # errors
          expect(r.stderr.chomp).to match(%r{The JKS keystore.*pkcs12"\.$}) if r.exit_code == 1
        end
      end
    end
  end
end
