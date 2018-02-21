#!/usr/bin/env rspec
require 'spec_helper'

describe Puppet::Type.type(:java_ks).provider(:keytool) do
  let(:temp_dir) do
    if Puppet.features.microsoft_windows?
      ENV['TEMP']
    else
      '/tmp/'
    end
  end

  let(:global_params) do
    {
      title: "app.example.com:#{temp_dir}application.jks",
      name: 'app.example.com',
      target: "#{temp_dir}application.jks",
      password: 'puppet',
      certificate: "#{temp_dir}app.example.com.pem",
      private_key: "#{temp_dir}private/app.example.com.pem",
      storetype: 'jceks',
      provider: described_class.name,
    }
  end
  let(:params) do
    global_params
  end

  let(:resource) do
    Puppet::Type.type(:java_ks).new(params)
  end

  let(:provider) do
    resource.provider
  end

  before(:each) do
    provider.stubs(:command).with(:keytool).returns('mykeytool')
    provider.stubs(:command).with(:openssl).returns('myopenssl')

    provider.stubs(:command_keytool).returns 'mykeytool'
    provider.stubs(:command_openssl).returns 'myopenssl'

    tempfile = stub('tempfile', class: Tempfile,
                                write: true,
                                flush: true,
                                close!: true,
                                path: "#{temp_dir}testing.stuff")
    Tempfile.stubs(:new).returns(tempfile)
  end

  describe 'when updating a certificate' do
    it 'calls destroy and create' do
      provider.expects(:destroy)
      provider.expects(:create)
      provider.update
    end
  end

  describe 'when running keystore commands', if: !Puppet.features.microsoft_windows? do
    it 'calls the passed command' do
      cmd = '/bin/echo testing 1 2 3'

      exec_class = if Puppet::Util::Execution.respond_to?(:execute)
                     Puppet::Util::Execution
                   else
                     Puppet::Util
                   end
      exec_class.expects(:execute).with(
        cmd,
        failonfail: true,
        combine: true,
      )
      provider.run_command(cmd)
    end

    context 'short timeout' do
      let(:params) do
        global_params.merge(keytool_timeout: 0.1)
      end

      it 'errors if timeout occurs' do
        cmd = 'sleep 1'

        expect { provider.run_command(cmd) }.to raise_error Puppet::Error, "Timed out waiting for 'app.example.com' to run keytool"
      end
    end

    it 'normallies timeout after 120 seconds' do
      cmd = '/bin/echo testing 1 2 3'
      Timeout.expects(:timeout).with(120, Timeout::Error).raises(Timeout::Error)

      expect { provider.run_command(cmd) }.to raise_error Puppet::Error, "Timed out waiting for 'app.example.com' to run keytool"
    end
  end

  describe 'when importing a private key and certifcate' do
    describe '#to_pkcs12' do
      it 'converts a certificate to a pkcs12 file' do
        sleep 0.1 # due to https://github.com/mitchellh/vagrant/issues/5056
        testing_key = OpenSSL::PKey::RSA.new 1024
        testing_ca = OpenSSL::X509::Certificate.new
        testing_ca.serial = 1
        testing_ca.public_key = testing_key.public_key
        testing_subj = '/CN=Test CA/ST=Denial/L=Springfield/O=Dis/CN=www.example.com'
        testing_ca.subject = OpenSSL::X509::Name.parse testing_subj
        testing_ca.issuer = testing_ca.subject
        testing_ca.not_before = Time.now
        testing_ca.not_after = testing_ca.not_before + 360
        testing_ca.sign(testing_key, OpenSSL::Digest::SHA256.new)

        provider.stubs(:password).returns(resource[:password])
        File.stubs(:read).with(resource[:private_key]).returns('private key')
        File.stubs(:read).with(resource[:certificate]).returns(testing_ca.to_pem)
        OpenSSL::PKey::RSA.expects(:new).with('private key', 'puppet').returns('priv_obj')
        OpenSSL::X509::Certificate.expects(:new).with(testing_ca.to_pem.chomp).returns('cert_obj')

        pkcs_double = BogusPkcs.new
        pkcs_double.expects(:to_der)
        OpenSSL::PKCS12.expects(:create).with(resource[:password], resource[:name], 'priv_obj', 'cert_obj', []).returns(pkcs_double)
        provider.to_pkcs12("#{temp_dir}testing.stuff")
      end
    end

    describe '#import_ks' do
      it 'executes openssl and keytool with specific options' do
        provider.expects(:to_pkcs12).with("#{temp_dir}testing.stuff")
        provider.expects(:run_command).with(['mykeytool', '-importkeystore', '-srcstoretype', 'PKCS12', '-destkeystore',
                                             resource[:target], '-srckeystore', "#{temp_dir}testing.stuff", '-alias', resource[:name]], any_parameters)
        provider.import_ks
      end

      it 'uses destkeypass when provided' do
        dkp = resource.dup
        dkp[:destkeypass] = 'keypass'
        provider.expects(:to_pkcs12).with("#{temp_dir}testing.stuff")
        provider.expects(:run_command).with(['mykeytool', '-importkeystore', '-srcstoretype', 'PKCS12', '-destkeystore',
                                             dkp[:target], '-srckeystore', "#{temp_dir}testing.stuff", '-alias', dkp[:name], '-destkeypass', dkp[:destkeypass]], any_parameters)
        provider.import_ks
      end
    end
  end

  describe 'when importing a pkcs12 file' do
    let(:params) do
      {
        title: "app.example.com:#{temp_dir}testing.jks",
        name: 'app.example.com',
        target: "#{temp_dir}application.jks",
        password: 'puppet',
        certificate: "#{temp_dir}testing.p12",
        storetype: 'pkcs12',
        source_password: 'password',
        provider: described_class.name,
      }
    end

    let(:resource) do
      Puppet::Type.type(:java_ks).new(params)
    end

    let(:provider) do
      resource.provider
    end

    describe '#import_pkcs12' do
      it 'supports pkcs12 source' do
        pkcs12 = resource.dup
        pkcs12[:storetype] = 'pkcs12'
        provider.expects(:run_command).with(['mykeytool', '-importkeystore', '-srcstoretype', 'PKCS12', '-destkeystore', pkcs12[:target], '-srckeystore', "#{temp_dir}testing.p12"], any_parameters)
        provider.import_pkcs12
      end
    end
  end

  describe 'when creating entires in a keystore' do
    let(:params) do
      {
        title: "app.example.com:#{temp_dir}application.jks",
        name: 'app.example.com',
        target: "#{temp_dir}application.jks",
        password: 'puppet',
        certificate: "#{temp_dir}app.example.com.pem",
        private_key: "#{temp_dir}private/app.example.com.pem",
        provider: described_class.name,
      }
    end

    let(:resource) do
      Puppet::Type.type(:java_ks).new(params)
    end

    let(:provider) do
      resource.provider
    end

    it 'calls import_ks if private_key and certificate are provided' do
      provider.expects(:import_ks)
      provider.create
    end

    it 'calls keytool with specific options if only certificate is provided' do
      no_pk = resource.dup
      no_pk.delete(:private_key)
      provider.expects(:run_command).with(['mykeytool', '-importcert', '-noprompt', '-alias', no_pk[:name], '-file', no_pk[:certificate], '-keystore', no_pk[:target]], any_parameters)
      no_pk.provider.expects(:import_ks).never
      no_pk.provider.create
    end
  end

  describe 'when removing entries from keytool' do
    it 'executes keytool with a specific set of options' do
      provider.expects(:run_command).with(['mykeytool', '-delete', '-alias', resource[:name], '-keystore', resource[:target]], any_parameters)
      provider.destroy
    end
  end
end

class BogusPkcs
end
