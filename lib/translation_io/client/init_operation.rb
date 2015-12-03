require 'translation_io/client/init_operation/update_and_collect_po_files_step'
require 'translation_io/client/init_operation/create_yaml_po_files_step'
require 'translation_io/client/init_operation/cleanup_yaml_files_step'

module TranslationIO
  class Client
    class InitOperation < BaseOperation
      def run
        config = TranslationIO.config

        haml_source_files = config.haml_source_files
        slim_source_files = config.slim_source_files
        source_files      = config.source_files
        pot_path          = config.pot_path
        source_locale     = config.source_locale
        target_locales    = config.target_locales
        locales_path      = config.locales_path
        yaml_locales_path = config.yaml_locales_path
        yaml_file_paths   = config.yaml_file_paths

        unless config.disable_gettext
          BaseOperation::DumpHamlGettextKeysStep.new(haml_source_files).run
          BaseOperation::DumpSlimGettextKeysStep.new(slim_source_files).run
        end

        UpdatePotFileStep.new(pot_path, source_files).run(params)
        UpdateAndCollectPoFilesStep.new(target_locales, pot_path, locales_path).run(params)

        create_yaml_pot_files_step = CreateYamlPoFilesStep.new(source_locale, target_locales, yaml_file_paths)
        create_yaml_pot_files_step.run(params)

        all_used_yaml_locales   = (create_yaml_pot_files_step.all_used_yaml_locales.to_a.map(&:to_s) - [config.source_locale.to_s]).sort.map(&:to_s)
        yaml_locales_difference = (all_used_yaml_locales) - target_locales.sort.map(&:to_s)

        if yaml_locales_difference.any?
          puts
          puts "----------"
          puts "Your `config.target_locales` are [#{target_locales.join(', ')}]."
          puts "We have found some YAML keys for [#{all_used_yaml_locales.join(', ')}] and they don't match."
          puts "Some of these locales may be coming from your gems."
          puts "----------"
          puts "Do you want to continue? (y/N)"

          print "> "
          input = STDIN.gets.strip

          if input != 'y' && input != 'Y'
            exit(0)
          end
        end

        TranslationIO.info "Sending data to server"
        uri             = URI("#{client.endpoint}/projects/#{client.api_key}/init")
        parsed_response = BaseOperation.perform_request(uri, params)

        unless parsed_response.nil?
          BaseOperation::SaveNewPoFilesStep.new(target_locales, locales_path, parsed_response).run
          BaseOperation::SaveNewYamlFilesStep.new(target_locales, yaml_locales_path, parsed_response).run
          BaseOperation::SaveSpecialYamlFilesStep.new(source_locale, target_locales, yaml_locales_path, yaml_file_paths).run
          CleanupYamlFilesStep.new(source_locale, target_locales, yaml_file_paths, yaml_locales_path).run
          BaseOperation::CreateNewMoFilesStep.new(locales_path).run
        end

        cleanup
      end
    end
  end
end
