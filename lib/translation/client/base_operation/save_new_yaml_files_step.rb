module Translation
  class Client
    class BaseOperation
      class SaveNewYamlFilesStep
        def initialize(target_locales, yaml_locales_path, parsed_response)
          @target_locales    = target_locales
          @yaml_locales_path = yaml_locales_path
          @parsed_response   = parsed_response
        end

        def run
          Translation.info "Saving new translation YAML files."

          @target_locales.each do |target_locale|
            if @parsed_response.has_key?("yaml_po_data_#{target_locale}")
              FileUtils.mkdir_p(@yaml_locales_path)
              yaml_path = File.join(@yaml_locales_path, "translation.#{target_locale}.yml")
              Translation.info yaml_path, 2
              yaml_data = YAMLConversion.get_yaml_data_from_po_data(@parsed_response["yaml_po_data_#{target_locale}"], target_locale)

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
