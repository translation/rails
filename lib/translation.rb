require 'gettext'
require 'gettext/po'

require 'translation/config'
require 'translation/railtie'
require 'translation/client'
require 'translation/yaml_conversion'

module Translation
  class << self
    attr_reader :config, :client

    def configure(&block)
      yield @config = Config.new

      Object.send(:include, GetText)
      bindtextdomain(@config.text_domain, :path => @config.locales_path, :charset => 'utf-8')
      Object.textdomain(Translation.config.text_domain)
      @client = Client.new(@config.api_key, @config.endpoint)

      true
    end

    def locale_paths
      Dir["#{config.locales_path}/*"].select do |dir|
        File.directory?(dir) && Translation.config.target_locales.map(&:to_s).include?(File.basename(dir))
      end
    end

    def pot_path
      "#{Translation.config.locales_path}/app.pot"
    end

    def info(message, level = 0)
      indent = (1..level).to_a.collect { "   " }.join('')
      puts "#{indent}* #{message}"
    end

    def version
      Gem::Specification::find_by_name('translation').version.to_s
    end
  end

  module I18nExtensions
    def locale=(locale)
      # super(locale)
      # GetText.locale = @locale
      raise "yey"
    end

    def brol
      "brol 42"
    end
  end
end

require 'i18n'
require 'i18n/config'

module I18n
  class Config
    include Translation::I18nExtensions
  end
end
