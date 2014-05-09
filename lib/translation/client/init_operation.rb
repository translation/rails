require 'translation/client/init_operation/update_pot_file_step'
require 'translation/client/init_operation/update_and_collect_po_files_step'
require 'translation/client/init_operation/create_yaml_po_files_step'
require 'translation/client/init_operation/save_new_po_files_step'
require 'translation/client/init_operation/save_new_yaml_files_step'
require 'translation/client/init_operation/save_special_yaml_files_step'

module Translation
  class Client
    class InitOperation < BaseOperation
      def run
        pot_path          = Translation.pot_path
        target_locales    = Translation.target_locales
        locales_path      = Translation.locales_path
        yaml_locales_path = 'config/locales'
        yaml_file_paths   = I18n.load_path

        UpdatePotFileStep.new(pot_path, Dir['**/*.{rb,erb}']).run
        UpdateAndCollectPoFilesStep.new(target_locales, pot_path, locales_path).run
        CreateYamlPoFilesStep.new(target_locales, yaml_file_paths).run

        Translation.info "Sending data to server"
        uri             = URI("http://#{client.endpoint}/projects/#{client.api_key}/init")
        parsed_response = perform_request(uri, params)

        unless parsed_response.nil?
          SaveNewPoFilesStep.new(target_locales, locales_path, parsed_response).run
          SaveNewYamlFileStep.new(target_locales, yaml_locales_path, parsed_response).run
          SaveSpecialYamlFilesStep.new(target_locales, yaml_locales_path, yaml_file_paths)
          cleanup_yaml_files
        end
      end

      private

      def cleanup_yaml_files
        I18n.load_path.each do |locale_file_path|
          in_project = locale_file_path_in_project?(locale_file_path)

          protected_file = Translation.config.target_locales.any? do |target_locale|
            [ Rails.root.join('config', 'locales', "translation.#{target_locale}.yml").to_s,
              Rails.root.join('config', 'locales', "localization.#{target_locale}.yml").to_s ].include?(locale_file_path)
          end

          if in_project && !protected_file
            content_hash     = YAML::load(File.read(locale_file_path))
            new_content_hash = content_hash.keep_if { |k| k.to_s == Translation.config.source_locale.to_s }

            if new_content_hash.keys.any?
              Translation.info("Rewriting #{locale_file_path}", 2)
              File.open(locale_file_path, 'wb') do |file|
                file.write(new_content_hash.to_yaml)
              end
            else
              Translation.info("Removing #{locale_file_path}", 2)
              FileUtils.rm(locale_file_path)
            end
          end
        end
      end
    end
  end
end
