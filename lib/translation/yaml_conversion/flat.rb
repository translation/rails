module Translation
  module YAMLConversion
    module Flat
      class << self
        def get_flat_translations_for_locale(locale)
          flat_translations = {}

          I18n.load_path.each do |locale_file_path|
            content           = File.read(locale_file_path)
            translations      = YAML::load(content)

            if translations.has_key?(locale.to_s)
              flat_translations.merge!(
                get_flat_translations_for_level(translations[locale.to_s], locale_file_path)
              )
            end
          end

          flat_translations
        end

        private

        def get_flat_translations_for_level(translations, locale_file_path, parent_key = nil)
          flat_translations = {}

          translations.each_pair do |key, value|
            current_level_key = [ parent_key, key ].reject(&:blank?).join('.')

            if value.is_a? Hash
              flat_translations.merge!(
                get_flat_translations_for_level(value, locale_file_path, current_level_key)
              )
            elsif value.is_a? String
              flat_translations[current_level_key] = {
                :locale_file_path => locale_file_path,
                :translation      => value
              }
            elsif value.is_a? Integer
              flat_translations[current_level_key] = {
                :locale_file_path => locale_file_path,
                :translation      => value.to_s
              }
            else
              # TODO : Boolean, Array, Integer
              {}
            end
          end

          flat_translations
        end
      end
    end
  end
end
