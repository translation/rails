module Translation
  class Client
    class SyncOperation < BaseOperation
      class UpdatePotFileStep
        attr_reader :params

        def initialize(pot_path, source_files)
          @pot_path     = pot_path
          @source_files = source_files
          @params       = {}
        end

        def run
          Translation.info "Updating POT file."
          GetText::Tools::XGetText.run(*@source_files, '-o', @pot_path)
          params['pot_data'] = File.read(@pot_path)
        end
      end
    end
  end
end
