!#/usr/bin/env rspec
require 'spec_helper'

describe Puppet::Type.type(:java_ks) do

  before do
    @app_example_com = {
      :title       => 'app.example.com:/tmp/application.jks',
      :name        => 'app.example.com',
      :target      => '/tmp/application.jks',
      :password    => 'puppet',
      :certificate => '/tmp/app.example.com.pem',
      :private_key => '/tmp/private/app.example.com.pem',
      :provider    => :keytool
    }
    @provider = stub('provider', :class => Puppet::Type.type(:java_ks).defaultprovider, :clear => nil)
    Puppet::Type.type(:java_ks).defaultprovider.stubs(:new).returns(@provider)
  end

  let(:jks_resource) do
    @app_example_com
  end

  it 'should default to being present' do
    Puppet::Type.type(:java_ks).new(@app_example_com)[:ensure].should == :present
  end

  describe 'when validating attributes' do

    [:name, :target, :private_key, :certificate, :password, :password_file, :trustcacerts].each do |param|
      it "should have a #{param} parameter" do
        Puppet::Type.type(:java_ks).attrtype(param).should == :param
      end
    end

    [:ensure].each do |prop|
      it "should have a #{prop} property" do
        Puppet::Type.type(:java_ks).attrtype(prop).should == :property
      end
    end
  end

  describe 'when validating attribute values' do

    [:present, :absent, :latest].each do |value|
      it "should support #{value} as a value to ensure" do
        Puppet::Type.type(:java_ks).new(jks_resource.merge({ :ensure => value }))
      end
    end

    it "first half of title should map to name parameter" do
      jks = jks_resource.dup
      jks.delete(:name)
      Puppet::Type.type(:java_ks).new(jks)[:name].should == jks_resource[:name]
    end

    it "second half of title should map to target parameter when no target is supplied" do
      jks = jks_resource.dup
      jks.delete(:target)
      Puppet::Type.type(:java_ks).new(jks)[:target].should == jks_resource[:target]
    end

    it "second half of title should not map to target parameter when target is supplied" do
      jks = jks_resource.dup
      jks[:target] = '/tmp/some_other_app.jks'
      Puppet::Type.type(:java_ks).new(jks)[:target].should_not == jks_resource[:target]
      Puppet::Type.type(:java_ks).new(jks)[:target].should == '/tmp/some_other_app.jks'
    end

    it 'title components should map to namevar parameters' do
      jks = jks_resource.dup
      jks.delete(:name)
      jks.delete(:target)
      Puppet::Type.type(:java_ks).new(jks)[:name].should == jks_resource[:name]
      Puppet::Type.type(:java_ks).new(jks)[:target].should == jks_resource[:target]
    end

    it 'should downcase :name values' do
      jks = jks_resource.dup
      jks[:name] = 'APP.EXAMPLE.COM'
      Puppet::Type.type(:java_ks).new(jks)[:name].should == jks_resource[:name]
    end
 
    it 'should have :false value to :trustcacerts when parameter not provided' do
      Puppet::Type.type(:java_ks).new(jks_resource)[:trustcacerts].should == :false
    end

    it 'should fail if both :password and :password_file are provided' do
      jks = jks_resource.dup
      jks[:password_file] = '/path/to/password_file'
      expect {
        Puppet::Type.type(:java_ks).new(jks)
      }.to raise_error(Puppet::Error, /You must pass either/)
    end

    it 'should fail if neither :password or :password_file is provided' do
      jks = jks_resource.dup
      jks.delete(:password)
      expect {
        Puppet::Type.type(:java_ks).new(jks)
      }.to raise_error(Puppet::Error, /You must pass one of/)
    end

    it 'should fail if :password is fewer than 6 characters' do
      jks = jks_resource.dup
      jks[:password] = 'aoeui'
      expect {
        Puppet::Type.type(:java_ks).new(jks)
      }.to raise_error(Puppet::Error, /length 6/)
    end
  end

  describe 'when ensure is set to latest' do
    it 'insync? should return false if md5 fingerprints do not match and state is :present' do
      jks = jks_resource.dup
      jks[:ensure] = :latest
      @provider.stubs(:latest).returns('AF:61:1C:FF:C7:C0:B2:C6:37:C5:D1:6E:00:AB:7A:B2')
      @provider.stubs(:current).returns('B4:54:EB:55:86:41:84:2E:22:A0:6A:36:1B:28:47:76')
      Puppet::Type.type(:java_ks).new(jks).property(:ensure).insync?(:present).should be_false
    end

    it 'insync? should return false if state is :absent' do
      jks = jks_resource.dup
      jks[:ensure] = :latest
      Puppet::Type.type(:java_ks).new(jks).property(:ensure).insync?(:absent).should be_false
    end

    it 'insync? should return true if md5 fingerprints match and state is :present' do
      jks = jks_resource.dup
      jks[:ensure] = :latest
      @provider.stubs(:latest).returns('AF:61:1C:FF:C7:C0:B2:C6:37:C5:D1:6E:00:AB:7A:B2')
      @provider.stubs(:current).returns('AF:61:1C:FF:C7:C0:B2:C6:37:C5:D1:6E:00:AB:7A:B2')
      Puppet::Type.type(:java_ks).new(jks).property(:ensure).insync?(:present).should be_true
    end
  end

  describe 'when file resources are in the catalog' do
    before do
      @file_provider = stub('provider', :class => Puppet::Type.type(:file).defaultprovider, :clear => nil)
      Puppet::Type.type(:file).defaultprovider.stubs(:new).returns(@file_provider)
    end

    [:private_key, :certificate].each do |file|
      it "should autorequire for #{file}" do
        test_jks = Puppet::Type.type(:java_ks).new(jks_resource)
        test_file = Puppet::Type.type(:file).new({:title => jks_resource[file]})

        config = Puppet::Resource::Catalog.new :testing do |conf|
          [test_jks, test_file].each do |resource| conf.add_resource resource end
        end

        rel = test_jks.autorequire[0]
        rel.source.ref.should == test_file.ref
        rel.target.ref.should == test_jks.ref
      end
    end

    it 'should autorequire for the :target directory' do
      test_jks = Puppet::Type.type(:java_ks).new(jks_resource)
      test_file = Puppet::Type.type(:file).new({:title => ::File.dirname(jks_resource[:target])})

      config = Puppet::Resource::Catalog.new :testing do |conf|
        [test_jks, test_file].each do |resource| conf.add_resource resource end
      end

      rel = test_jks.autorequire[0]
      rel.source.ref.should == test_file.ref
      rel.target.ref.should == test_jks.ref
    end
  end
end
