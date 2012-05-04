#!/usr/bin/env rspec
require 'spec_helper'

describe Puppet::Type.type(:java_ks).provider(:keytool) do

  before do
    @app_example_com = {
        :title       => 'app.example.com:/tmp/application.jks',
        :name        => 'app.example.com',
        :target      => '/tmp/application.jks',
        :password    => 'puppet',
        :certificate => '/tmp/app.example.com.pem',
        :private_key => '/tmp/private/app.example.com.pem',
        :provider    => described_class.name
    }
    provider.stubs(:command).with(:keytool).returns('mykeytool')
    provider.stubs(:command).with(:openssl).returns('myopenssl')

    tempfile = stub('tempfile', :class => Tempfile,
                :write => true,
                :flush => true,
                :close! => true,
                :path => '/tmp/testing.stuff'
               )
    Tempfile.stubs(:new).returns(tempfile)
  end

  let(:resource) do
    Puppet::Type.type(:java_ks).new @app_example_com
  end

  let(:provider) do
    resource.provider
  end

  let(:app_example_com) do
    @app_example_com
  end

  describe 'when updating a certificate' do
    it 'should call destroy and create' do
      provider.expects(:destroy)
      provider.expects(:create)
      provider.update
    end
  end

  describe 'when importing a private key and certifcate' do
    it 'should execute openssl and keytool with specific options' do
      Puppet::Util.expects(:execute).with do |args|
        args[0] == [
          'myopenssl', 'pkcs12', '-export', '-passout', 'stdin',
          '-in', resource[:certificate],
          '-inkey', resource[:private_key],
          '-name', resource[:name]
        ]
      end
      Puppet::Util.expects(:execute).with do |args|
        args[0] == [
          'mykeytool', '-importkeystore', '-srcstoretype', 'PKCS12',
          '-destkeystore', resource[:target],
          '-srckeystore', '/tmp/testing.stuff',
          '-alias', resource[:name]
        ]
      end
      provider.import_ks
    end
  end

  describe 'when creating entires in a keystore' do
    it 'should call import_ks if private_key and certificate are provided' do
      provider.expects(:import_ks)
      provider.create
    end

    it 'should call keytool with specific options if only certificate is provided' do
      no_pk = resource.dup
      no_pk.delete(:private_key)
      Puppet::Util.expects(:execute).with do |args|
        args[0] == [
          'mykeytool', '-importcert', '-noprompt',
          '-alias', no_pk[:name],
          '-file', no_pk[:certificate],
          '-keystore', no_pk[:target]
        ]
      end
      no_pk.provider.expects(:import_ks).never
      no_pk.provider.create
    end
  end

  describe 'when removing entries from keytool' do
    it 'should execute keytool with a specific set of options' do
      Puppet::Util.expects(:execute).with do |args|
        args[0] == [
          'mykeytool', '-delete',
          '-alias', resource[:name],
          '-keystore', resource[:target]
        ]
      end
      provider.destroy
    end
  end
end
