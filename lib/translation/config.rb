module Translation
  class Config
    attr_accessor :api_key, :locales_path
    attr_accessor :source_locale, :target_locales
    attr_accessor :endpoint
    attr_accessor :verbose

    def initialize
      self.locales_path   = File.join('config', 'locales', 'gettext')
      self.source_locale  = :en
      self.target_locales = [:fr, :nl, :de]
      self.endpoint       = 'rails.translation.io/api'
      self.verbose        = true
    end

    def to_s
      "#{api_key} — #{source_locale} => #{target_locales.join(' + ')}"
    end
  end
end
