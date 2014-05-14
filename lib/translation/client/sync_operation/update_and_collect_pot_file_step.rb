module Translation
  class Client
    class SyncOperation < BaseOperation
      class UpdateAndCollectPotFileStep
        def initialize(pot_path, source_files)
          @pot_path     = pot_path
          @source_files = source_files
        end

        def run(params)
          Translation.info "Updating POT file."
          GetText::Tools::XGetText.run(*@source_files, '-o', @pot_path)
          params['pot_data'] = File.read(@pot_path)
        end
      end
    end
  end
end
