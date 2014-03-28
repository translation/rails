require 'gettext'
require 'translation/config'
require 'translation/railtie'

module Translation
  class << self
    attr_reader :config

    def configure(&block)
      yield @config = Config.new

      Object.send(:include, GetText)
      bindtextdomain(@config.text_domain, :path => @config.locales_path)
      Object.textdomain(Translation.config.text_domain)
    end
  end
end
