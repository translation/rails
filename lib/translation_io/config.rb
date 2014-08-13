module TranslationIO
  class Config
    attr_accessor :api_key, :locales_path
    attr_accessor :source_locale, :target_locales
    attr_accessor :endpoint
    attr_accessor :verbose

    def initialize
      self.locales_path   = File.join('config', 'locales', 'gettext')
      self.source_locale  = :en
      self.target_locales = []
      self.endpoint       = 'api.translation.io/api'
      self.verbose        = 1
    end

    def to_s
      "#{api_key} - #{source_locale} => #{target_locales.join(' + ')}"
    end
  end
end
