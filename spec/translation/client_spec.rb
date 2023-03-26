require 'spec_helper'

describe TranslationIO::Client do
  before :each do
    @client = TranslationIO::Client.new('4242', 'https://bidule.com/api')
  end

  it do
    @client.api_key.should  == '4242'
    @client.endpoint.should == 'https://bidule.com/api'
  end

  it do
    @client.should respond_to :init
    @client.should respond_to :sync
    @client.should respond_to :sync_and_purge
  end
end
