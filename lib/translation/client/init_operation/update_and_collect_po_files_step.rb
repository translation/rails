module Translation
  class Client
    class InitOperation < BaseOperation
      class UpdateAndCollectPoFilesStep
        def initialize(target_locales, pot_path, locales_path)
          @target_locales = target_locales
          @pot_path       = pot_path
          @locales_path   = locales_path
        end

        def run(params)
          Translation.info "Updating PO files."

          @target_locales.each do |target_locale|
            po_path = "#{@locales_path}/#{target_locale.gsub('-', '_')}/#{TEXT_DOMAIN}.po"
            Translation.info po_path, 2, 2

            if File.exist?(po_path)
              GetText::Tools::MsgMerge.run(po_path, @pot_path, '-o', po_path)
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
