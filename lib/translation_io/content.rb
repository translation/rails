require 'translation_io/content/config'
require 'translation_io/content/storage'
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
        storage = storage_class.new
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

      def perform_request(uri, params = {})
        begin
          params.merge!({
            'gem_version'        => TranslationIO.version,
            'source_language'    => config.source_locale.to_s,
            'target_languages[]' => config.target_locales.map(&:to_s)
          })

          http = Net::HTTP.new(uri.host, uri.port)
          http.use_ssl = uri.scheme == 'https'
          http.read_timeout = 500

          request = Net::HTTP::Post.new(uri.request_uri)
          request.set_form_data(params)

          response        = http.request(request)
          parsed_response = JSON.parse(response.body)

          if response.code.to_i == 200
            return parsed_response
          elsif response.code.to_i == 400 && parsed_response.has_key?('error')
            $stderr.puts "[Error] #{parsed_response['error']}"
            exit
          else
            $stderr.puts "[Error] Unknown error from the server: #{response.code}."
            exit
          end
        rescue Errno::ECONNREFUSED
          $stderr.puts "[Error] Server not responding."
          exit
        end
      end
    end
  end
end
