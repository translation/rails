module Translation
  class Client
    class InitOperation < BaseOperation

      def run
        update_pot_file
        update_and_collect_po_files
        create_yaml_po_files

        uri             = URI("http://#{client.endpoint}/projects/#{client.api_key}/init")
        parsed_response = perform_request(uri, params)

        unless parsed_response.nil?
          save_new_po_files
          save_new_yaml_po_files
          save_special_yaml_files
        end
      end

      private

      def update_pot_file
        Translation.info "Updating POT file."
        pot_path = Translation.pot_path
        source_files = Dir['**/*.{rb,erb}']
        GetText::Tools::XGetText.run(*source_files, '-o', pot_path)
      end

      def update_and_collect_po_files
        Translation.info "Updating PO files."

        Translation.config.target_locales.each do |target_locale|
          po_path = "#{Translation.config.locales_path}/#{target_locale}/app.po"
          Translation.info po_path, 2

          if File.exist?(po_path)
            GetText::Tools::MsgMerge.run(po_path, Translation.pot_path, '-o', po_path)
          else
            FileUtils.mkdir_p(File.dirname(po_path))
            FileUtils.copy(Translation.pot_path, po_path)
          end

          params["po_data_#{target_locale}"] = File.read(po_path)
        end
      end

      def create_yaml_po_files
        Translation.info "Importing translations from YAML files."
        all_flat_translations  = {}

        I18n.load_path.each do |file_path|
          Translation.info file_path, 2
          all_flat_translations.merge!(YAMLConversion::Flat.get_flat_translations_for_yaml_file(file_path))
        end

        all_flat_string_translations = all_flat_translations.select do |key, value|
          value[:translation].is_a?(String)
        end

        source_flat_string_tanslations = all_flat_string_translations.select do |key|
          key.starts_with?("#{Translation.config.source_locale}.")
        end

        Translation.config.target_locales.each do |target_locale|
          target_locale_translations = all_flat_string_translations.select do |key|
            if key.starts_with?("#{target_locale}.")
              source_key = key.gsub(/\A#{target_locale}\./, "#{Translation.config.source_locale}.")
              source_flat_string_tanslations.has_key?(source_key)
            else
              false
            end
          end

          po_representation  = GetText::PO.new

          target_locale_translations.each_pair do |key, value|
            source_key = key.gsub(/\A#{target_locale}\./, "#{Translation.config.source_locale}.")
            msgid      = source_flat_string_tanslations[source_key][:translation]

            unless msgid.blank?
              po_entry            = GetText::POEntry.new(:msgctxt)
              po_entry.msgid      = msgid
              po_entry.msgstr     = value[:translation]
              po_entry.msgctxt    = key
              po_entry.references = [ value[:locale_file_path] ]

              po_representation[po_entry.msgctxt, po_entry.msgid] = po_entry
            end
          end

          params["yaml_po_data_#{target_locale}"] = po_representation.to_s
        end
      end

      def save_new_po_files
        Translation.info "Saving new PO files."

        Translation.config.target_locales.each do |target_locale|
          if params.has_key?("po_data_#{target_locale}")
            po_path = File.join(Translation.config.locales_path, target_locale.to_s, 'app.po')
            Translation.info po_path, 2

            File.open(po_path, 'wb') do |file|
              file.write(params["po_data_#{target_locale}"])
            end
          end
        end
      end

      def save_new_yaml_po_files
        Translation.info "Saving new translation YAML files."

        Translation.config.target_locales.each do |target_locale|
          if params.has_key?("yaml_po_data_#{target_locale}")
            yaml_path = File.join('config', "translation.#{target_locale}.yml")
            Translation.info yaml_path, 2
            yaml_data = YAMLConversion.get_yaml_data_from_po_data(params["yaml_po_data_#{target_locale}"])

            File.open(yaml_path, 'wb') do |file|
              file.write(yaml_data)
            end
          end
        end
      end

      def save_special_yaml_files
        Translation.info "Saving new localization YAML files (with non-string values)."
        all_flat_translations  = {}

        I18n.load_path.each do |file_path|
          all_flat_translations.merge!(YAMLConversion::Flat.get_flat_translations_for_yaml_file(file_path))
        end

        all_flat_special_translations = all_flat_translations.select do |key, value|
          not value[:translation].is_a?(String)
        end

        source_flat_special_tanslations = all_flat_special_translations.select do |key|
          key.starts_with?("#{Translation.config.source_locale}.")
        end

        Translation.config.target_locales.each do |target_locale|
          yaml_path = File.join('config', "localization.#{target_locale}.yml")
          Translation.info yaml_path, 2
          flat_translations = {}

          source_flat_special_tanslations.each_pair do |key, value|
            target_key = key.gsub(/\A#{Translation.config.source_locale}\./, "#{target_locale}.")

            if all_flat_special_translations.has_key?(target_key)
              flat_translations[key] = all_flat_special_translations[target_key]
            end
          end

          yaml_data = YAMLConversion::Flat.get_yaml_from_flat_yaml(flat_translations)

          File.open(yaml_path, 'wb') do |file|
            file.write(yaml_data)
          end
        end
      end
    end
  end
end
