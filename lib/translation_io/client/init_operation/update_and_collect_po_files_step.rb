module TranslationIO
  class Client
    class InitOperation < BaseOperation
      class UpdateAndCollectPoFilesStep
        def initialize(target_locales, pot_path, locales_path)
          @target_locales = target_locales
          @pot_path       = pot_path
          @locales_path   = locales_path
        end

        def run(params)
          TranslationIO.info "Updating PO files."

          text_domain = TranslationIO.config.text_domain

          @target_locales.each do |target_locale|
            po_path = "#{@locales_path}/#{Locale::Tag.parse(target_locale).to_s}/#{text_domain}.po"
            TranslationIO.info po_path, 2, 2

            if File.exist?(po_path)
              GetText::Tools::MsgMerge.run(po_path, @pot_path, '-o', po_path, '--no-fuzzy-matching', '--no-obsolete-entries')
            else
              FileUtils.mkdir_p(File.dirname(po_path))
              GetText::Tools::MsgInit.run('-i', @pot_path, '-o', po_path, '-l', target_locale, '--no-translator')
            end

            params["po_data_#{target_locale}"] = File.read(po_path)
          end

          return self
        end
      end
    end
  end
end
