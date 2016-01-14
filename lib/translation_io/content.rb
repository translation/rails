require 'translation_io/content/storage'
require 'translation_io/content/init'
require 'translation_io/content/sync'

module TranslationIO
  module Content
    @@translated_fields = {}

    class << self
      attr_reader :config, :client

      def configure(&block)
        @config ||= Content::Config.new
        yield @config
        @client = Client.new(@config.api_key, @config.endpoint)
        return true
      end

      def translated_fields
        @@translated_fields
      end

      def register_translated_field(class_name, field_name)
        @@translated_fields[class_name] ||= []
        @@translated_fields[class_name] << field_name.to_s
      end
    end

    class Config
      attr_accessor :api_key, :locales_path, :yaml_locales_path
      attr_accessor :source_locale, :target_locales
      attr_accessor :endpoint
      attr_accessor :verbose
      attr_accessor :test

      def initialize
        self.locales_path      = File.join('config', 'locales', 'gettext')
        self.yaml_locales_path = File.join('config', 'locales')
        self.source_locale     = :en
        self.target_locales    = []
        self.endpoint          = 'https://translation.io/api'
        self.verbose           = 1
        self.test              = false
      end

      def to_s
        "content — #{api_key} - #{source_locale} => #{target_locales.join(' + ')}"
      end
    end
  end
end
