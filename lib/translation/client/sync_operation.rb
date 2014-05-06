module Translation
  class Client
    class SyncOperation < BaseOperation

      def run
        update_pot_file
        create_yaml_po_files

        uri             = URI("http://#{client.endpoint}/projects/#{client.api_key}/sync")
        parsed_response = perform_request(uri, params)

        unless parsed_response.nil?
          save_new_po_files(parsed_response)
          create_new_mo_files
          save_new_yaml_files(parsed_response)
          save_special_yaml_files(parsed_response)
        end
      end

      private

      def update_pot_file
        Translation.info "Updating POT file."
        pot_path = Translation.pot_path
        source_files = Dir['**/*.{rb,erb}']
        GetText::Tools::XGetText.run(*source_files, '-o', pot_path)
        params['pot_data'] = File.read(pot_path)
      end

      def create_yaml_po_files
        Translation.info "Generation POT file from YAML files."

        all_flat_translations  = {}

        I18n.load_path.each do |file_path|
          Translation.info file_path, 2
          all_flat_translations.merge!(YAMLConversion.get_flat_translations_for_yaml_file(file_path))
        end

        source_flat_string_tanslations = all_flat_translations.select do |key, value|
          value.is_a?(String) && key.start_with?("#{Translation.config.source_locale}.")
        end

        pot_representation = GetText::PO.new

        source_flat_string_tanslations.each_pair do |key, value|
          msgid = value

          unless msgid.blank?
            pot_entry            = GetText::POEntry.new(:msgctxt)
            pot_entry.msgid      = msgid
            pot_entry.msgstr     = ''
            pot_entry.msgctxt    = key.split('.', 2).last
            pot_entry.references = [ value[:locale_file_path] ]

            pot_representation[pot_entry.msgctxt, pot_entry.msgid] = pot_entry
          end
        end

        params['yaml_pot_data'] = pot_representation.to_s
      end

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

      def create_new_mo_files
        Translation.info "Creating new MO files."

        Translation.locale_paths.each do |locale_path|
          po_path = "#{locale_path}/app.po"
          mo_path = "#{locale_path}/LC_MESSAGES/app.mo"

          Translation.info mo_path, 2

          FileUtils.mkdir_p("#{locale_path}/LC_MESSAGES")
          GetText::Tools::MsgFmt.run(po_path, '-o', mo_path)
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

      def save_special_yaml_files(parsed_response)
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

    end
  end
end
