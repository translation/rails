module Translation
  class Client
    class SyncOperation < BaseOperation
      class SaveNewYamlFilesStep
        def run
          Translation.info "Saving new translation YAML files."

          Translation.config.target_locales.each do |target_locale|
            if parsed_response.has_key?("yaml_po_data_#{target_locale}")
              yaml_path = File.join('config', 'locales', "translation.#{target_locale}.yml")
              Translation.info yaml_path, 2
              yaml_data = YAMLConversion.get_yaml_data_from_po_data(parsed_response["yaml_po_data_#{target_locale}"], target_locale)

              File.open(yaml_path, 'wb') do |file|
                file.write(yaml_data)
              end
            end
          end
        end
      end
    end
  end
end
