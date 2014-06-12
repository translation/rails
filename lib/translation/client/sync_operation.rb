require 'translation/client/sync_operation/update_and_collect_pot_file_step'
require 'translation/client/sync_operation/create_yaml_pot_file_step'

module Translation
  class Client
    class SyncOperation < BaseOperation
      def run(purge = false)
        source_files      = Dir['**/*.{rb,erb}']
        pot_path          = Translation.pot_path
        source_locale     = Translation.config.source_locale
        target_locales    = Translation.config.target_locales
        locales_path      = Translation.config.locales_path
        yaml_locales_path = 'config/locales'
        yaml_file_paths   = I18n.load_path

        UpdateAndCollectPotFileStep.new(pot_path, source_files).run(params)
        CreateYamlPotFileStep.new(source_locale, yaml_file_paths).run(params)

        if purge
          params['purge'] = 'true'
        end

        uri             = URI("http://#{client.endpoint}/projects/#{client.api_key}/sync")
        parsed_response = perform_request(uri, params)

        unless parsed_response.nil?
          BaseOperation::SaveNewPoFilesStep.new(target_locales, locales_path, parsed_response).run
          BaseOperation::CreateNewMoFilesStep.new(locales_path).run
          BaseOperation::SaveNewYamlFilesStep.new(target_locales, yaml_locales_path, parsed_response).run
          BaseOperation::SaveSpecialYamlFilesStep.new(source_locale, target_locales, yaml_locales_path, yaml_file_paths).run
        end
      end
    end
  end
end
