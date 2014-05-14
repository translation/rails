require 'translation/client/sync_operation/update_and_collect_pot_file_step'
require 'translation/client/sync_operation/create_yaml_pot_file_step'
require 'translation/client/sync_operation/create_new_mo_files_step'

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

        UpdateAndCollectPotFileStep.new(pot_path, source_files).run
        CreateYamlPotFileStep.new(source_locale, yaml_file_paths).run

        uri             = URI("http://#{client.endpoint}/projects/#{client.api_key}/sync")
        parsed_response = perform_request(uri, params)

        unless parsed_response.nil?
          BaseOperation::SaveNewPoFiles.new(target_locales, locales_path, parsed_response).run
          CreateNewMoFiles.new(locales_path).run
          BaseOperation::SaveNewYamlFiles.new(target_locales, yaml_locales_path, parsed_response).run
          BaseOperation::SaveSpecialYamlFiles.new(source_locale, target_locales, yaml_locales_path, yaml_file_paths).run
        end
      end
    end
  end
end
