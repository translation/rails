module Translation
  class Client
    class InitOperation < BaseOperation
      class CleanupYamlFilesStep
        # attr_accessor :pot_path, :source_files

        # def initialize(pot_path, source_files)
        #   @pot_path     = pot_path
        #   @source_files = source_files
        # end

        # def run
        #   Translation.info "Updating POT file."
        #   FileUtils.mkdir_p(File.dirname(pot_path))
        #   GetText::Tools::XGetText.run(*source_files, '-o', pot_path)
        # end
      end
    end
  end
end
