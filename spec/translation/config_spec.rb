require 'spec_helper'

describe Translation::Config do
  it "stores the configuration options" do
    Translation.configure do |config|
      config.api_key        = '424242'
      config.source_locale  = :en
      config.target_locales = [:fr, :nl]
      config.endpoint       = 'localhost:3001/api'
    end

    Translation.config.api_key.should        == '424242'
    Translation.config.source_locale.should  == :en
    Translation.config.target_locales.should == [:fr, :nl]
    Translation.config.endpoint.should       == 'localhost:3001/api'
  end
end
