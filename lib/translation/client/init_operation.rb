require 'translation/client/init_operation/update_pot_file_step'
require 'translation/client/init_operation/update_and_collect_po_files_step'
require 'translation/client/init_operation/create_yaml_po_files_step'

module Translation
  class Client
    class InitOperation < BaseOperation

      def run
        pot_path        = Translation.pot_path
        target_locales  = Translation.target_locales
        locales_path    = Translation.locales_path
        yaml_file_paths = I18n.load_path

        UpdatePotFileStep.new(pot_path, Dir['**/*.{rb,erb}']).run
        UpdateAndCollectPoFilesStep.new(target_locales, pot_path, locales_path).run
        CreateYamlPoFilesStep.new(target_locales, yaml_file_paths).run

        create_yaml_po_files

        Translation.info "Sending data to server"
        uri             = URI("http://#{client.endpoint}/projects/#{client.api_key}/init")
        parsed_response = perform_request(uri, params)

        unless parsed_response.nil?
          save_new_po_files(parsed_response)
          save_new_yaml_files(parsed_response)
          save_special_yaml_files
          cleanup_yaml_files
        end
      end

      private

      def save_new_po_files(parsed_response)
        Translation.info "Saving new PO files."

        Translation.config.target_locales.each do |target_locale|
          if parsed_response.has_key?("po_data_#{target_locale}")
            po_path = File.join(Translation.config.locales_path, target_locale.to_s, 'app.po')
            Translation.info po_path, 2

            File.open(po_path, 'wb') do |file|
              file.write(parsed_response["po_data_#{target_locale}"])
            end
          end
        end
      end

      def save_new_yaml_files(parsed_response)
        Translation.info "Saving new translation YAML files."

        Translation.config.target_locales.each do |target_locale|
          if parsed_response.has_key?("yaml_po_data_#{target_locale}")
            yaml_path = File.join('config', 'locales', "translation.#{target_locale}.yml")
            Translation.info yaml_path, 2
            yaml_data = YAMLConversion.get_yaml_data_from_po_data(parsed_response["yaml_po_data_#{target_locale}"], target_locale)

            File.open(yaml_path, 'wb') do |file|
              file.write(yaml_data)
            end
          end
        end
      end

      def save_special_yaml_files
        Translation.info "Saving new localization YAML files (with non-string values)."
        all_flat_translations = {}

        I18n.load_path.each do |file_path|
          all_flat_translations.merge!(YAMLConversion.get_flat_translations_for_yaml_file(file_path))
        end

        # all_flat_translations.each_pair do |key, value|
        #   all_flat_translations[key] = value
        # end

        all_flat_special_translations = all_flat_translations.select do |key, value|
          not value.is_a?(String)
        end

        source_flat_special_translations = all_flat_special_translations.select do |key|
          key.start_with?("#{Translation.config.source_locale}.")
        end

        Translation.config.target_locales.each do |target_locale|
          yaml_path = File.join('config', 'locales', "localization.#{target_locale}.yml")
          Translation.info yaml_path, 2
          flat_translations = {}

          source_flat_special_translations.each_pair do |key, value|
            target_key = key.gsub(/\A#{Translation.config.source_locale}\./, "#{target_locale}.")
            flat_translations[target_key] = all_flat_special_translations[target_key]
          end

          yaml_data = YAMLConversion.get_yaml_data_from_flat_translations(flat_translations)

          File.open(yaml_path, 'wb') do |file|
            file.write(yaml_data)
          end
        end
      end

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
