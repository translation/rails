module TranslationIO
  class Client
    class BaseOperation
      class SaveNewPoFilesStep
        def initialize(target_locales, locales_path, parsed_response)
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

          return self
        end
      end
    end
  end
end
