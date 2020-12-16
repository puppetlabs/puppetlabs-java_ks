# frozen_string_literal: true

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
    allow(provider).to receive(:command).with(:keytool).and_return('mykeytool')
    allow(provider).to receive(:command).with(:openssl).and_return('myopenssl')

    allow(provider).to receive(:command_keytool).and_return('mykeytool')
    allow(provider).to receive(:command_openssl).and_return('myopenssl')

    tempfile = class_double('tempfile', class: Tempfile,
                                        write: true,
                                        flush: true,
                                        close!: true,
                                        path: "#{temp_dir}testing.stuff")
    allow(Tempfile).to receive(:new).and_return(tempfile)
  end

  describe 'when updating a certificate' do
    it 'calls destroy and create' do
      expect(provider).to receive(:destroy)
      expect(provider).to receive(:create)
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
      expect(exec_class).to receive(:execute).with(
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

    it 'normally times out after 120 seconds' do
      cmd = '/bin/echo testing 1 2 3'
      expect(Timeout).to receive(:timeout).with(120, Timeout::Error).and_raise(Timeout::Error)

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

        allow(provider).to receive(:password).and_return(resource[:password])
        allow(File).to receive(:read).with(resource[:private_key]).and_return('private key')
        allow(File).to receive(:read).with(resource[:certificate], hash_including(encoding: 'ISO-8859-1')).and_return(testing_ca.to_pem)
        expect(OpenSSL::PKey::RSA).to receive(:new).with('private key', 'puppet').and_return('priv_obj')
        expect(OpenSSL::X509::Certificate).to receive(:new).with(testing_ca.to_pem.chomp).and_return('cert_obj')

        pkcs_double = BogusPkcs.new
        expect(pkcs_double).to receive(:to_der)
        expect(OpenSSL::PKCS12).to receive(:create).with(resource[:password], resource[:name], 'priv_obj', 'cert_obj', []).and_return(pkcs_double)
        provider.to_pkcs12("#{temp_dir}testing.stuff")
      end
    end

    describe '#import_ks' do
      it 'executes openssl and keytool with specific options' do
        expect(provider).to receive(:to_pkcs12).with("#{temp_dir}testing.stuff")
        expect(provider).to receive(:run_command).with(['mykeytool', '-importkeystore', '-srcstoretype', 'PKCS12', '-destkeystore',
                                                        resource[:target], '-srckeystore', "#{temp_dir}testing.stuff", '-alias', resource[:name]], any_args)
        provider.import_ks
      end

      it 'uses destkeypass when provided' do
        dkp = resource.dup
        dkp[:destkeypass] = 'keypass'
        expect(provider).to receive(:to_pkcs12).with("#{temp_dir}testing.stuff")
        expect(provider).to receive(:run_command).with(['mykeytool', '-importkeystore', '-srcstoretype', 'PKCS12', '-destkeystore',
                                                        dkp[:target], '-srckeystore', "#{temp_dir}testing.stuff", '-alias', dkp[:name], '-destkeypass', dkp[:destkeypass]], any_args)
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
        expect(provider).to receive(:run_command).with(['mykeytool', '-importkeystore', '-srcstoretype',
                                                        'PKCS12', '-destkeystore', pkcs12[:target], '-srckeystore', "#{temp_dir}testing.p12"], any_args)
        provider.import_pkcs12
      end
    end
  end

  describe 'when creating entries in a keystore' do
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
      expect(provider).to receive(:import_ks)
      provider.create
    end

    it 'calls keytool with specific options if only certificate is provided' do
      no_pk = resource.dup
      no_pk.delete(:private_key)
      expect(provider).to receive(:run_command).with(['mykeytool', '-importcert', '-noprompt', '-alias', no_pk[:name], '-file', no_pk[:certificate], '-keystore', no_pk[:target]], any_args)
      expect(no_pk.provider).to receive(:import_ks).never
      no_pk.provider.create
    end
  end

  describe 'when removing entries from keytool' do
    it 'executes keytool with a specific set of options' do
      expect(provider).to receive(:run_command).with(['mykeytool', '-delete', '-alias', resource[:name], '-keystore', resource[:target], '-storetype', resource[:storetype]], any_args)
      provider.destroy
    end
  end
end

class BogusPkcs
end
