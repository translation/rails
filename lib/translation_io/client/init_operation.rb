require 'translation_io/client/init_operation/update_pot_file_step'
require 'translation_io/client/init_operation/update_and_collect_po_files_step'
require 'translation_io/client/init_operation/create_yaml_po_files_step'
require 'translation_io/client/init_operation/cleanup_yaml_files_step'

module TranslationIO
  class Client
    class InitOperation < BaseOperation
      def run
        haml_source_files = Dir['**/*.{haml}']
        slim_source_files = Dir['**/*.{slim}']

        BaseOperation::DumpHamlGettextKeysStep.new(haml_source_files).run
        BaseOperation::DumpSlimGettextKeysStep.new(slim_source_files).run

        source_files      = Dir[SOURCE_FILES_PATTERN]
        pot_path          = TranslationIO.pot_path
        source_locale     = TranslationIO.config.source_locale
        target_locales    = TranslationIO.config.target_locales
        locales_path      = TranslationIO.config.locales_path
        yaml_locales_path = 'config/locales'
        yaml_file_paths   = I18n.load_path

        UpdatePotFileStep.new(pot_path, source_files).run
        UpdateAndCollectPoFilesStep.new(target_locales, pot_path, locales_path).run(params)
        CreateYamlPoFilesStep.new(source_locale, target_locales, yaml_file_paths).run(params)

        TranslationIO.info "Sending data to server"
        uri             = URI("http://#{client.endpoint}/projects/#{client.api_key}/init")
        parsed_response = perform_request(uri, params)

        unless parsed_response.nil?
          BaseOperation::SaveNewPoFilesStep.new(target_locales, locales_path, parsed_response).run
          BaseOperation::SaveNewYamlFilesStep.new(target_locales, yaml_locales_path, parsed_response).run
          BaseOperation::SaveSpecialYamlFilesStep.new(source_locale, target_locales, yaml_locales_path, yaml_file_paths).run
          CleanupYamlFilesStep.new(source_locale, target_locales, yaml_file_paths, yaml_locales_path).run
          BaseOperation::CreateNewMoFilesStep.new(locales_path).run
        end
      end
    end
  end
end
