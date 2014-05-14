require 'translation/client/sync_operation/update_pot_file_step'
require 'translation/client/sync_operation/create_yaml_po_files_step'
require 'translation/client/sync_operation/save_new_po_files_step'
require 'translation/client/sync_operation/create_new_mo_files_step'
require 'translation/client/sync_operation/save_new_yaml_files_step'
require 'translation/client/sync_operation/save_special_yaml_files_step'

module Translation
  class Client
    class SyncOperation < BaseOperation
      def run
        source_files      = Dir['**/*.{rb,erb}']
        pot_path          = Translation.pot_path
        source_locale     = Translation.config.source_locale
        target_locales    = Translation.config.target_locales
        locales_path      = Translation.locales_path
        yaml_locales_path = 'config/locales'
        yaml_file_paths   = I18n.load_path

        UpdatePotFileStep.new(pot_path, source_files).run
        CreateYamlPoFilesStep.new(source_locale, yaml_file_paths).run

        uri             = URI("http://#{client.endpoint}/projects/#{client.api_key}/sync")
        parsed_response = perform_request(uri, params)

        unless parsed_response.nil?
          SaveNewPoFiles.new(target_locales, locales_path, parsed_response).run
          CreateNewMoFiles.new(target_locales, locales_path, parsed_response).run
          SaveNewYamlFiles.new(target_locales, yaml_locales_path, parsed_response).run
          SaveSpecialYamlFiles.new(source_locale, target_locales, yaml_locales_path, yaml_file_paths).run
        end
      end
    end
  end
end
