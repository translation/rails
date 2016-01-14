module TranslationIO
  module Content
    class Config
      attr_accessor :api_key, :locales_path, :yaml_locales_path
      attr_accessor :source_locale, :target_locales
      attr_accessor :field_accessors
      attr_accessor :storage
      attr_accessor :endpoint
      attr_accessor :verbose
      attr_accessor :test

      def initialize
        self.locales_path      = File.join('config', 'locales', 'gettext')
        self.yaml_locales_path = File.join('config', 'locales')
        self.source_locale     = :en
        self.target_locales    = []
        self.field_accessors   = true
        self.endpoint          = 'https://translation.io/api'
        self.verbose           = 1
        self.test              = false
        self.storage           = Storage::SuffixStorage.new
      end

      def to_s
        "content — #{api_key} - #{source_locale} => #{target_locales.join(' + ')}"
      end
    end
  end
end
