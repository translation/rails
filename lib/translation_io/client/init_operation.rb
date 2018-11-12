require 'translation_io/client/init_operation/update_and_collect_po_files_step'
require 'translation_io/client/init_operation/create_yaml_po_files_step'
require 'translation_io/client/init_operation/cleanup_yaml_files_step'

module TranslationIO
  class Client
    class InitOperation < BaseOperation
      def run
        config = TranslationIO.config

        source_files      = config.source_files
        erb_source_files  = config.erb_source_files
        haml_source_files = config.haml_source_files
        slim_source_files = config.slim_source_files
        pot_path          = config.pot_path
        source_locale     = config.source_locale
        target_locales    = config.target_locales
        locales_path      = config.locales_path
        yaml_locales_path = config.yaml_locales_path
        yaml_file_paths   = config.yaml_file_paths

        unless config.disable_gettext
          BaseOperation::DumpMarkupGettextKeysStep.new(haml_source_files, :haml).run
          BaseOperation::DumpMarkupGettextKeysStep.new(slim_source_files, :slim).run
        end

        UpdatePotFileStep.new(pot_path, source_files + erb_source_files).run(params)
        UpdateAndCollectPoFilesStep.new(target_locales, pot_path, locales_path).run(params)

        create_yaml_pot_files_step = CreateYamlPoFilesStep.new(source_locale, target_locales, yaml_file_paths)
        create_yaml_pot_files_step.run(params)

        all_used_yaml_locales = create_yaml_pot_files_step.all_used_yaml_locales.to_a.map(&:to_s).sort

        warn_source_locale_unfound(source_locale, all_used_yaml_locales)
        warn_target_locale_unfound(target_locales, all_used_yaml_locales)

        TranslationIO.info "Sending data to server (it may take some time, please be patient. Sync will be faster)."

        uri             = URI("#{client.endpoint}/projects/#{client.api_key}/init")
        parsed_response = BaseOperation.perform_request(uri, params)

        unless parsed_response.nil?
          BaseOperation::SaveNewPoFilesStep.new(target_locales, locales_path, parsed_response).run
          BaseOperation::SaveNewYamlFilesStep.new(target_locales, yaml_locales_path, parsed_response).run
          BaseOperation::SaveSpecialYamlFilesStep.new(source_locale, target_locales, yaml_locales_path, yaml_file_paths).run
          CleanupYamlFilesStep.new(source_locale, target_locales, yaml_file_paths, yaml_locales_path).run
          BaseOperation::CreateNewMoFilesStep.new(locales_path).run

          info_yaml_directory_structure
          info_project_url(parsed_response)
        end

        cleanup
      end

      def warn_source_locale_unfound(source_locale, all_used_yaml_locales)
        is_source_locale_unfound = !source_locale.in?(all_used_yaml_locales)

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
            exit(true)
          end
        end
      end

      def warn_target_locale_unfound(target_locales, all_used_yaml_locales)
        target_locales_unfound = target_locales - all_used_yaml_locales

        if target_locales_unfound.any?
          puts
          puts "----------"
          puts "Your `config.target_locales` are [#{target_locales.sort.join(', ')}]."
          puts "But we haven't found any YAML key for [#{target_locales_unfound.join(', ')}], is this normal?"
          puts "If not, check that you haven't misspelled the locale (ex. 'en-GB' instead of 'en')."
          puts "----------"
          puts "Do you want to continue? (y/N)"

          print "> "
          input = STDIN.gets.strip

          if input != 'y' && input != 'Y'
            exit(true)
          end
        end
      end

      def info_yaml_directory_structure
        puts
        puts "----------"
        puts "If you're wondering why your YAML directory structure has changed so much,"
        puts "please check this article: https://translation.io/blog/dealing-with-yaml-files-and-their-directory-structure"
        puts "----------"
      end

      def info_project_url(parsed_response)
        puts
        puts "----------"
        puts "Use this URL to translate: #{parsed_response['project_url']}"
        puts "Then use 'rake translation:sync' to send new keys to Translation.io and get new translations into your project."
        puts "----------"
      end
    end
  end
end
