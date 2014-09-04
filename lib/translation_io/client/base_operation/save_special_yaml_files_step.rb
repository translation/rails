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

          source_flat_special_translations = all_flat_special_translations.select do |key|
            YamlEntry.from_locale?(key, @source_locale) && !YamlEntry.ignored?(key, @source_locale)
          end

          @target_locales.each do |target_locale|
            yaml_path = File.join(@yaml_locales_path, "localization.#{target_locale}.yml")

            TranslationIO.info yaml_path, 2, 2
            flat_translations = {}

            source_flat_special_translations.each_pair do |key, value|
              target_key = key.gsub(/\A#{@source_locale}\./, "#{target_locale}.")
              flat_translations[target_key] = all_flat_special_translations[target_key]
            end

            yaml_data = YAMLConversion.get_yaml_data_from_flat_translations(flat_translations)

            File.open(yaml_path, 'wb') do |file|
              file.write(yaml_data)
            end
          end

          if not TranslationIO.config.test
            # Get YAML localization entries
            params = {}
            @target_locales.each do |target_locale|
              yaml_path = File.join(@yaml_locales_path, "localization.#{target_locale}.yml")
              params["yaml_data_#{target_locale}"] = File.read(yaml_path)
            end

            TranslationIO.info "Collecting YAML localization entries"
            uri             = URI("http://#{TranslationIO.client.endpoint}/projects/#{TranslationIO.client.api_key}/fill_yaml_localizations")
            parsed_response = BaseOperation.perform_request(uri, params)

            unless parsed_response.nil?
              @target_locales.each do |target_locale|
                yaml_path = File.join(@yaml_locales_path, "localization.#{target_locale}.yml")

                File.open(yaml_path, 'wb') do |file|
                  file.write(parsed_response["yaml_data_#{target_locale}"])
                end
              end
            end
          end
        end

      end
    end
  end
end
