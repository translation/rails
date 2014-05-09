module Translation
  class Client
    class SyncOperation < BaseOperation
      class SaveNewPoFilesStep
        def run
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
      end
    end
  end
end
