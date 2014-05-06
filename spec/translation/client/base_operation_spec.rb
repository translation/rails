require 'spec_helper'

describe Translation::Client::BaseOperation do
  before :each do
    Translation.configure do |config|
      config.target_locales = ['fr', 'nl']
    end

    @client    = Translation::Client.new('4242', 'bidule.com/api')
    @operation = Translation::Client::BaseOperation.new(@client)
  end

  it 'has default values initialized' do
    @operation.client.should                       == @client
    @operation.params['gem_version'].should        == Translation.version
    @operation.params['target_languages[]'].should == ['fr', 'nl']
  end
end
