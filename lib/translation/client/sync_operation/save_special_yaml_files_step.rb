module Translation
  class Client
    class SyncOperation < BaseOperation
      class SaveSpecialYamlFilesStep
        def initialize(source_locale, target_locales, yaml_locales_path, yaml_file_paths)
          @source_locale     = source_locale
          @target_locales    = target_locales
          @yaml_locales_path = yaml_locales_path
          @yaml_file_paths   = yaml_file_paths
        end

        def run
          Translation.info "Saving new localization YAML files (with non-string values)."
          all_flat_translations = {}

          @yaml_file_paths.each do |file_path|
            all_flat_translations.merge!(
              YAMLConversion.get_flat_translations_for_yaml_file(file_path)
            )
          end

          all_flat_special_translations = all_flat_translations.select do |key, value|
            not value.is_a?(String)
          end

          source_flat_special_translations = all_flat_special_translations.select do |key|
            key.start_with?("#{@source_locale}.")
          end

          @target_locales.each do |target_locale|
            yaml_path = File.join(@yaml_locales_path, "localization.#{target_locale}.yml")
            Translation.info yaml_path, 2
            flat_translations = {}

            source_flat_special_translations.each_pair do |key, value|
              target_key = key.gsub(/\A#{Translation.config.source_locale}\./, "#{target_locale}.")
              flat_translations[target_key] = all_flat_special_translations[target_key]
            end

            yaml_data = YAMLConversion.get_yaml_data_from_flat_translations(flat_translations)

            File.open(yaml_path, 'wb') do |file|
              file.write(yaml_data)
            end
          end
        end
      end
    end
  end
end
