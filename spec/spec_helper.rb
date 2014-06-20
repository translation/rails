require 'rails'
require 'yaml'
require 'translation'

Translation.configure do |config|
  config.verbose = -1
end

RSpec.configure do |config|
  config.before :each do
    if File.exist?('tmp')
      FileUtils.rm_r('tmp')
    end

    FileUtils.mkdir_p('tmp')
  end
end
