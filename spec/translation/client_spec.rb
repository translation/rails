require 'spec_helper'

describe Translation::Client do
  before :each do
    @client = Translation::Client.new('4242', 'bidule.com/api')
  end

  it do
    @client.api_key.should  == '4242'
    @client.endpoint.should == 'bidule.com/api'
  end

  it do
    @client.should respond_to :init
    @client.should respond_to :sync
    @client.should respond_to :purge
  end
end
