require 'translation/client/init_operation/update_pot_file_step'
require 'translation/client/init_operation/update_and_collect_po_files_step'
require 'translation/client/init_operation/create_yaml_po_files_step'
require 'translation/client/init_operation/cleanup_yaml_files_step'

module Translation
  class Client
    class InitOperation < BaseOperation
      def run
        source_files      = Dir['**/*.{rb,erb}']
        pot_path          = Translation.pot_path
        source_locale     = Translation.config.source_locale
        target_locales    = Translation.config.target_locales
        locales_path      = Translation.locales_path
        yaml_locales_path = 'config/locales'
        yaml_file_paths   = I18n.load_path

        UpdatePotFileStep.new(pot_path, source_files).run
        UpdateAndCollectPoFilesStep.new(target_locales, pot_path, locales_path).run(params)
        CreateYamlPoFilesStep.new(target_locales, yaml_file_paths).run(params)

        Translation.info "Sending data to server"
        uri             = URI("http://#{client.endpoint}/projects/#{client.api_key}/init")
        parsed_response = perform_request(uri, params)

        unless parsed_response.nil?
          BaseOperation::SaveNewPoFilesStep.new(target_locales, locales_path, parsed_response).run
          BaseOperation::SaveNewYamlFileStep.new(target_locales, yaml_locales_path, parsed_response).run
          BaseOperation::SaveSpecialYamlFilesStep.new(target_locales, yaml_locales_path, yaml_file_paths).run
          CleanupYamlFilesStep.new(target_locales, yaml_file_paths).run
        end
      end
    end
  end
end
