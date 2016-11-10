module TranslationIO
  module Content
    class Config
      attr_accessor :api_key
      attr_accessor :source_locale, :target_locales
      attr_accessor :field_accessors
      attr_accessor :storage
      attr_accessor :endpoint

      def initialize
        self.source_locale   = :en
        self.target_locales  = []
        self.field_accessors = true
        self.endpoint        = 'https://translation.io/api'

        if defined?(Globalize)
          self.storage = :globalize
        else
          self.storage = :suffix
        end
      end

      def to_s
        "content — #{api_key} - #{source_locale} => #{target_locales.join(' + ')}"
      end
    end
  end
end
