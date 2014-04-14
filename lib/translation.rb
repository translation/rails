require 'gettext'
require 'gettext/po'

require 'translation/config'
require 'translation/railtie'
require 'translation/webservice_client'
require 'translation/yaml_conversion'

module Translation
  class << self
    attr_reader :config, :webservice_client

    def configure(&block)
      yield @config = Config.new

      Object.send(:include, GetText)
      bindtextdomain(@config.text_domain, :path => @config.locales_path, :charset => 'utf-8')
      Object.textdomain(Translation.config.text_domain)
      @webservice_client = WebserviceClient.new(@config.api_key, @config.endpoint)

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
      puts "* #{message}"
    end
  end
end
