require 'spec_helper'

describe TranslationIO::Client::BaseOperation do
  before :each do
    TranslationIO.configure do |config|
      config.target_locales = ['fr', 'nl']
    end

    @client    = TranslationIO::Client.new('4242', 'bidule.com/api')
    @operation = TranslationIO::Client::BaseOperation.new(@client)
  end

  it 'has default values initialized' do
    @operation.client.should == @client
  end
end
