module TranslationIO
  class Client
    class BaseOperation
      class SaveSpecialYamlFilesStep

        def initialize(source_locale, target_locales, yaml_locales_path, yaml_file_paths)
          @source_locale     = source_locale
          @target_locales    = target_locales
          @yaml_locales_path = yaml_locales_path
          @yaml_file_paths   = yaml_file_paths
        end

        def run
          TranslationIO.info "Saving new localization YAML files (with non-string values)."
          all_flat_translations = {}

          @yaml_file_paths.each do |file_path|
            all_flat_translations.merge!(
              YAMLConversion.get_flat_translations_for_yaml_file(file_path)
            )
          end

          all_flat_special_translations = all_flat_translations.select do |key, value|
            YamlEntry.localization?(key, value)
          end

          @target_locales.each do |target_locale|
            yaml_path = File.join(@yaml_locales_path, "localization.#{target_locale}.yml")

            TranslationIO.info yaml_path, 2, 2

            target_flat_special_translations = all_flat_special_translations.select do |key|
              YamlEntry.from_locale?(key, target_locale) && !YamlEntry.ignored?(key)
            end

            yaml_data = YAMLConversion.get_yaml_data_from_flat_translations(target_flat_special_translations)

            if !YAML::load(yaml_data).empty?
              File.open(yaml_path, 'wb') do |file|
                file.write(self.class.top_comment)
                file.write(yaml_data)
              end
            end
          end

          if !TranslationIO.config.test
            # Get YAML localization entries
            params = {}
            @target_locales.each do |target_locale|
              yaml_path = File.join(@yaml_locales_path, "localization.#{target_locale}.yml")
              params["yaml_data_#{target_locale}"] = File.read(yaml_path)
            end

            TranslationIO.info "Collecting YAML localization entries from server."

            uri             = URI("#{TranslationIO.client.endpoint}/projects/#{TranslationIO.client.api_key}/fill_yaml_localizations")
            parsed_response = BaseOperation.perform_request(uri, params)

            unless parsed_response.nil?
              @target_locales.each do |target_locale|
                yaml_path = File.join(@yaml_locales_path, "localization.#{target_locale}.yml")

                File.open(yaml_path, 'wb') do |file|
                  file.write(self.class.top_comment)
                  file.write(parsed_response["yaml_data_#{target_locale}"])
                end
              end
            end
          end
        end

        def self.top_comment
          <<EOS
# THIS FILE CONTAINS LOCALIZATION KEYS : date and number formats, number precisions,
# number separators and all non-textual values depending on the language.
# These values must not reach the translator, so they are separated in this file.
#
# More info here: https://translation.io/blog/gettext-is-better-than-rails-i18n#localization
#
# You can edit and/or add new localization keys here, they won't be touched by Translation.io.
#
# If you want to add a new localization key prefix, use the option described here:
# https://github.com/translation/rails#custom-localization-key-prefixes
#
EOS
        end

      end
    end
  end
end
