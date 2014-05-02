require 'gettext'
require 'gettext/po'

require 'translation/config'
require 'translation/railtie'
require 'translation/client'
require 'translation/flat_hash'
require 'translation/yaml_conversion'

module Translation
  class << self
    attr_reader :config, :client

    def configure(&block)
      yield @config = Config.new

      Object.send(:include, GetText)
      bindtextdomain('app', :path => @config.locales_path, :charset => 'utf-8')
      Object.textdomain('app')
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
end
