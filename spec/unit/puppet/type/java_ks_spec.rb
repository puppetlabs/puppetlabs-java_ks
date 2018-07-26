! # /usr/bin/env rspec
require 'spec_helper'

describe Puppet::Type.type(:java_ks) do
  let(:temp_dir) do
    if Puppet.features.microsoft_windows?
      ENV['TEMP']
    else
      '/tmp/'
    end
  end
  let(:provider_var) { stub('provider', class: Puppet::Type.type(:java_ks).defaultprovider, clear: nil) }
  let(:app_example_com) do
    {
      title: "app.example.com:#{temp_dir}application.jks",
      name: 'app.example.com',
      target: "#{temp_dir}application.jks",
      password: 'puppet',
      destkeypass: 'keypass',
      certificate: "#{temp_dir}app.example.com.pem",
      private_key: "#{temp_dir}private/app.example.com.pem",
      private_key_type: 'rsa',
      storetype: 'jceks',
      provider: :keytool,
    }
  end
  let(:jks_resource) do
    app_example_com
  end

  before(:each) do
    Puppet::Type.type(:java_ks).defaultprovider.stubs(:new).returns(provider_var)
  end

  it 'defaults to being present' do
    expect(Puppet::Type.type(:java_ks).new(app_example_com)[:ensure]).to eq(:present)
  end

  describe 'when validating attributes' do
    [:name, :target, :private_key, :private_key_type, :certificate, :password, :password_file, :trustcacerts, :destkeypass, :password_fail_reset, :source_password].each do |param|
      it "should have a #{param} parameter" do
        expect(Puppet::Type.type(:java_ks).attrtype(param)).to eq(:param)
      end
    end

    [:ensure].each do |prop|
      it "should have a #{prop} property" do
        expect(Puppet::Type.type(:java_ks).attrtype(prop)).to eq(:property)
      end
    end
  end

  describe 'when validating attribute values' do
    [:present, :absent, :latest].each do |value|
      it "should support #{value} as a value to ensure" do
        Puppet::Type.type(:java_ks).new(jks_resource.merge(ensure: value))
      end
    end

    it 'first half of title should map to name parameter' do
      jks = jks_resource.dup
      jks.delete(:name)
      expect(Puppet::Type.type(:java_ks).new(jks)[:name]).to eq(jks_resource[:name])
    end

    it 'second half of title should map to target parameter when no target is supplied' do
      jks = jks_resource.dup
      jks.delete(:target)
      expect(Puppet::Type.type(:java_ks).new(jks)[:target]).to eq(jks_resource[:target])
    end

    it 'second half of title should not map to target parameter when target is supplied #not to equal' do
      jks = jks_resource.dup
      jks[:target] = "#{temp_dir}some_other_app.jks"
      expect(Puppet::Type.type(:java_ks).new(jks)[:target]).not_to eq(jks_resource[:target])
    end
    it 'second half of title should not map to target parameter when target is supplied #to equal' do
      jks = jks_resource.dup
      jks[:target] = "#{temp_dir}some_other_app.jks"
      expect(Puppet::Type.type(:java_ks).new(jks)[:target]).to eq("#{temp_dir}some_other_app.jks")
    end

    it 'title components should map to namevar parameters #name' do
      jks = jks_resource.dup
      jks.delete(:name)
      jks.delete(:target)
      expect(Puppet::Type.type(:java_ks).new(jks)[:name]).to eq(jks_resource[:name])
    end
    it 'title components should map to namevar parameters #target' do
      jks = jks_resource.dup
      jks.delete(:name)
      jks.delete(:target)
      expect(Puppet::Type.type(:java_ks).new(jks)[:target]).to eq(jks_resource[:target])
    end

    it 'downcases :name values' do
      jks = jks_resource.dup
      jks[:name] = 'APP.EXAMPLE.COM'
      expect(Puppet::Type.type(:java_ks).new(jks)[:name]).to eq(jks_resource[:name])
    end

    it 'has :false value to :trustcacerts when parameter not provided' do
      expect(Puppet::Type.type(:java_ks).new(jks_resource)[:trustcacerts]).to eq(:false)
    end

    it 'has :rsa as the default value for :private_key_type' do
      expect(Puppet::Type.type(:java_ks).new(jks_resource)[:private_key_type]).to eq(:rsa)
    end

    it 'fails if :private_key_type is neither :rsa nor :ec' do
      jks = jks_resource.dup
      jks[:private_key_type] = 'nosuchkeytype'

      expect {
        Puppet::Type.type(:java_ks).new(jks)
      }.to raise_error(Puppet::Error)
    end

    it 'fails if both :password and :password_file are provided' do
      jks = jks_resource.dup
      jks[:password_file] = '/path/to/password_file'
      expect {
        Puppet::Type.type(:java_ks).new(jks)
      }.to raise_error(Puppet::Error, %r{You must pass either})
    end

    it 'fails if neither :password or :password_file is provided' do
      jks = jks_resource.dup
      jks.delete(:password)
      expect {
        Puppet::Type.type(:java_ks).new(jks)
      }.to raise_error(Puppet::Error, %r{You must pass one of})
    end

    it 'fails if :password is fewer than 6 characters' do
      jks = jks_resource.dup
      jks[:password] = 'aoeui'
      expect {
        Puppet::Type.type(:java_ks).new(jks)
      }.to raise_error(Puppet::Error, %r{6 characters})
    end

    it 'fails if :destkeypass is fewer than 6 characters' do
      jks = jks_resource.dup
      jks[:destkeypass] = 'aoeui'
      expect {
        Puppet::Type.type(:java_ks).new(jks)
      }.to raise_error(Puppet::Error, %r{length 6})
    end

    it 'has :false value to :password_fail_reset when parameter not provided' do
      expect(Puppet::Type.type(:java_ks).new(jks_resource)[:password_fail_reset]).to eq(:false)
    end

    it 'fails if :source_password is not provided for pkcs12 :storetype' do
      jks = jks_resource.dup
      jks[:storetype] = 'pkcs12'
      expect {
        Puppet::Type.type(:java_ks).new(jks)
      }.to raise_error(Puppet::Error, %r{You must provide 'source_password' when using a 'pkcs12' storetype})
    end
  end

  describe 'when ensure is set to latest' do
    it 'insync? should return false if sha1 fingerprints do not match and state is :present' do
      jks = jks_resource.dup
      jks[:ensure] = :latest
      provider_var.stubs(:latest).returns('9B:8B:23:4C:6A:9A:08:F6:4E:B6:01:23:EA:5A:E7:8F:6A')
      provider_var.stubs(:current).returns('21:46:45:65:57:50:FE:2D:DA:7C:C8:57:D2:33:3A:B0:A6')
      expect(Puppet::Type.type(:java_ks).new(jks).property(:ensure)).not_to be_insync(:present)
    end

    it 'insync? should return false if state is :absent' do
      jks = jks_resource.dup
      jks[:ensure] = :latest
      expect(Puppet::Type.type(:java_ks).new(jks).property(:ensure)).not_to be_insync(:absent)
    end

    it 'insync? should return true if sha1 fingerprints match and state is :present' do
      jks = jks_resource.dup
      jks[:ensure] = :latest
      provider_var.stubs(:latest).returns('66:9B:8B:23:4C:6A:9A:08:F6:4E:B6:01:23:EA:5A')
      provider_var.stubs(:current).returns('66:9B:8B:23:4C:6A:9A:08:F6:4E:B6:01:23:EA:5A')
      expect(Puppet::Type.type(:java_ks).new(jks).property(:ensure)).to be_insync(:present)
    end
  end

  describe 'when file resources are in the catalog' do
    let(:file_provider) { stub('provider', class: Puppet::Type.type(:file).defaultprovider, clear: nil) }

    before(:each) do
      Puppet::Type.type(:file).defaultprovider.stubs(:new).returns(file_provider)
    end

    [:private_key, :certificate].each do |file|
      it "should autorequire for #{file} #file" do
        test_jks = Puppet::Type.type(:java_ks).new(jks_resource)
        test_file = Puppet::Type.type(:file).new(title: jks_resource[file])

        Puppet::Resource::Catalog.new :testing do |conf|
          [test_jks, test_file].each { |resource| conf.add_resource resource }
        end

        rel = test_jks.autorequire[0]
        expect(rel.source.ref).to eq(test_file.ref)
      end
      it "should autorequire for #{file} #jks" do
        test_jks = Puppet::Type.type(:java_ks).new(jks_resource)
        test_file = Puppet::Type.type(:file).new(title: jks_resource[file])

        Puppet::Resource::Catalog.new :testing do |conf|
          [test_jks, test_file].each { |resource| conf.add_resource resource }
        end

        rel = test_jks.autorequire[0]
        expect(rel.target.ref).to eq(test_jks.ref)
      end
    end

    it 'autorequires for the :target directory #file' do
      test_jks = Puppet::Type.type(:java_ks).new(jks_resource)
      test_file = Puppet::Type.type(:file).new(title: ::File.dirname(jks_resource[:target]))

      Puppet::Resource::Catalog.new :testing do |conf|
        [test_jks, test_file].each { |resource| conf.add_resource resource }
      end

      rel = test_jks.autorequire[0]
      expect(rel.source.ref).to eq(test_file.ref)
    end
    it 'autorequires for the :target directory #jks' do
      test_jks = Puppet::Type.type(:java_ks).new(jks_resource)
      test_file = Puppet::Type.type(:file).new(title: ::File.dirname(jks_resource[:target]))

      Puppet::Resource::Catalog.new :testing do |conf|
        [test_jks, test_file].each { |resource| conf.add_resource resource }
      end

      rel = test_jks.autorequire[0]
      expect(rel.target.ref).to eq(test_jks.ref)
    end
  end
end
