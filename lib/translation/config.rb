module Translation
  class Config
    attr_accessor :api_key, :text_domain, :locales_path
    attr_accessor :source_locale, :target_locales

    def initialize
      self.text_domain    = 'app'
      self.locales_path   = File.join('config', 'locales', 'gettext')
      self.source_locale  = [:en]
      self.target_locales = [:fr, :nl]
    end

    def to_s
      api_key
    end
  end
end
