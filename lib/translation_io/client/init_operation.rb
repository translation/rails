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

        all_used_yaml_locales    = create_yaml_pot_files_step.all_used_yaml_locales.to_a.map(&:to_s).sort
        is_source_locale_unfound = !source_locale.in?(all_used_yaml_locales)
        unfound_target_locales   = target_locales - all_used_yaml_locales

        if is_source_locale_unfound
          puts
          puts "----------"
          puts "Your `config.source_locale` is \"#{source_locale}\" but no YAML keys were found for this locale."
          puts "Check that you haven't misspelled the locale (ex. 'en-GB' instead of 'en')."
          puts "----------"
          puts "Do you want to continue anyway? (y/N)"

          print "> "
          input = STDIN.gets.strip

          if input != 'y' && input != 'Y'
            exit(0)
          end
        end

        if unfound_target_locales.any?
          puts
          puts "----------"
          puts "Your `config.target_locales` are [#{target_locales.sort.join(', ')}]."
          puts "But we haven't found any YAML key for [#{unfound_target_locales.join(', ')}], is this normal?"
          puts "If not, check that you haven't misspelled the locale (ex. 'en-GB' instead of 'en')."
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
