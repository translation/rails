require 'translation_io/content/config'
require 'translation_io/content/storage'
require 'translation_io/content/request'
require 'translation_io/content/init'
require 'translation_io/content/sync'

module TranslationIO
  module Content
    @@translated_fields = {}

    class << self
      attr_reader :config, :storage

      def configure(&block)
        @config ||= Content::Config.new
        yield @config
        storage_class = "TranslationIO::Content::Storage::#{@config.storage.to_s.camelize}Storage".constantize
        @storage = storage_class.new
        return true
      end

      def translated_fields
        @@translated_fields
      end

      def register_translated_field(class_name, field_name)
        @@translated_fields[class_name.to_s] ||= []
        @@translated_fields[class_name.to_s] << field_name.to_s
      end

      def register_translated_fields_from_globalize
        if globalize?
          Rails.application.eager_load!

          ActiveRecord::Base.subclasses.each do |klass|
            if klass.translates?
              klass.translated_attribute_names.each do |attribute_name|
                register_translated_field(klass.name, attribute_name)
              end
            end
          end
        end
      end

      def define_field_accessors
        unless globalize?
          if config.field_accessors
            translated_fields.each_pair do |class_name, field_names|
              field_names.each do |field_name|
                class_name.constantize.send(:define_method, field_name.to_sym) do
                  storage.get(I18n.locale, self, field_name)
                end
              end
            end
          end
        end
      end

      def globalize?
        storage.is_a?(Storage::GlobalizeStorage)
      end

      def init
        TranslationIO::Content::Init.new.run
      end

      def sync
        TranslationIO::Content::Sync.new.run
      end
    end
  end
end
