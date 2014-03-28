require 'gettext'
require 'translation/config'
require 'translation/railtie'

module Translation
  class << self
    attr_reader :config

    def configure(&block)
      yield @config = Config.new

      Object.send(:include, GetText)
      bindtextdomain(@config.text_domain, :path => @config.locales_path, :charset => 'utf-8')
      Object.textdomain(Translation.config.text_domain)
    end

    def locale_paths
      Dir["#{config.locales_path}/*"].select do |dir|
        File.directory?(dir) && Translation.config.target_locales.map(&:to_s).include?(File.basename(dir))
      end
    end
  end
end
