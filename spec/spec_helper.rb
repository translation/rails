require 'simplecov'
SimpleCov.start

require 'rails'
require 'yaml'
require 'translation'

RSpec.configure do |config|
  config.before :each do
    TranslationIO.configure do |config|
      config.verbose                   = -1
      config.test                      = true
      config.source_locale             = :en
      config.target_locales            = []
      config.metadata_path             = 'tmp/config/locales/.translation_io'
      config.yaml_locales_path         = File.join('tmp', 'config', 'locales')
      config.ignored_key_prefixes      = []
      config.localization_key_prefixes = []
      config.yaml_line_width           = nil
      config.yaml_remove_empty_keys    = false
    end

    if File.exist?('tmp')
      FileUtils.rm_r('tmp')
    end

    FileUtils.mkdir_p('tmp')
  end
end
