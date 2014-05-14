module Translation
  class Client
    class SyncOperation < BaseOperation
      class SaveNewPoFilesStep
        def initialize(target_locales, locales_path, parsed_response)
          @target_locales  = target_locales
          @locales_path    = locales_path
          @parsed_response = parsed_response
        end

        def run
          Translation.info "Saving new PO files."

          @target_locales.each do |target_locale|
            if @parsed_response.has_key?("po_data_#{target_locale}")
              po_path = File.join(@locales_path, target_locale.to_s, 'app.po')
              FileUtils.mkdir_p(File.dirname(po_path))
              Translation.info po_path, 2

              File.open(po_path, 'wb') do |file|
                file.write(@parsed_response["po_data_#{target_locale}"])
              end
            end
          end
        end
      end
    end
  end
end
