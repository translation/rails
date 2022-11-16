module TranslationIO
  class Client
    class BaseOperation
      class SaveNewPoFilesStep
        def initialize(source_locale, target_locales, locales_path, parsed_response)
          @source_locale   = source_locale
          @target_locales  = target_locales
          @locales_path    = locales_path
          @parsed_response = parsed_response
        end

        def run
          TranslationIO.info "Saving new PO files."

          text_domain = TranslationIO.config.text_domain

          @target_locales.each do |target_locale|
            if @parsed_response.has_key?("po_data_#{target_locale}")
              po_path = File.join(@locales_path, Locale::Tag.parse(target_locale).to_s, "#{text_domain}.po")
              FileUtils.mkdir_p(File.dirname(po_path))
              TranslationIO.info po_path, 2, 2

              File.open(po_path, 'wb') do |file|
                file.write(@parsed_response["po_data_#{target_locale}"])
              end
            end
          end

          create_source_po(text_domain)

          return self
        end

        # Create source locale PO file, with identical source and target
        # => Useful for correct fallbacks (cf. discussion https://github.com/translation/rails/issues/48)
        def create_source_po(text_domain)
          source_locale = Locale::Tag.parse(@source_locale)

          pot_path = File.join(@locales_path, "#{text_domain}.pot")
          po_path  = File.join(@locales_path, source_locale.to_s, "#{text_domain}.po")

          FileUtils.mkdir_p(File.dirname(po_path))
          FileUtils.rm(po_path) if File.exist?(po_path)

          # Generate source PO from POT and parse it
          GetText::Tools::MsgInit.run('-i', pot_path, '-o', po_path, '-l', source_locale.to_s, '--no-translator')
          po_entries = GetText::PO.new
          GetText::POParser.new.parse(File.read(po_path), po_entries)

          # With GetText after 3.3.9 and the introduction of optional `red-datasets` dependency, we need to complete the plural forms manually
          # Source languages must have only 2 plural forms, and only 2 different pluralization rules exist for these languages
          if %w(ak am as bn fa fr gu hi hy kn ln mg nso pa si ti zu).include?(source_locale.language)
            po_entries[''].msgstr.gsub!('Plural-Forms: nplurals=; plural=;', 'Plural-Forms: nplurals=2; plural=n > 1;')  # 0 and 1 are singular
          else
            po_entries[''].msgstr.gsub!('Plural-Forms: nplurals=; plural=;', 'Plural-Forms: nplurals=2; plural=n != 1;') # only 1 is singular
          end

          # Fill with same target as source and save it
          po_entries.each do |po_entry|
            if po_entry.msgid != '' # header
              po_entry.msgstr = [po_entry.msgid, po_entry.msgid_plural].compact.join("\000")
            end
          end

          File.open(po_path, 'wb') do |file|
            file.write(po_entries.to_s)
          end
        end
      end
    end
  end
end
