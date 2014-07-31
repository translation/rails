module TranslationIO
  class Client
    class InitOperation < BaseOperation
      class UpdatePotFileStep
        def initialize(pot_path, source_files)
          @pot_path     = pot_path
          @source_files = source_files
        end

        def run
          TranslationIO.info "Updating POT file."
          FileUtils.mkdir_p(File.dirname(@pot_path))
          GetText::Tools::XGetText.run(*@source_files, '-o', @pot_path, '--msgid-bugs-address', 'contact@translation.io',)
        end
      end
    end
  end
end
