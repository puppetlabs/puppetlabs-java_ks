require 'spec_helper'

describe 'default' do
  it 'should work' do
    should contain_java_ks('puppetca:truststore')
  end
end
