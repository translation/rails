module TranslationIO
  class Client
    class InitOperation < BaseOperation
      class UpdatePotFileStep
        def initialize(pot_path, source_files)
          @pot_path     = pot_path
          @source_files = source_files
        end

        def run(params)
          TranslationIO.info "Updating POT file."
          FileUtils.mkdir_p(File.dirname(@pot_path))
          GetText::Tools::XGetText.run(*@source_files, '-o', @pot_path,
                                       '--msgid-bugs-address', TranslationIO.config.pot_msgid_bugs_address,
                                       '--package-name',       TranslationIO.config.pot_package_name,
                                       '--package-version',    TranslationIO.config.pot_package_version,
                                       '--copyright-holder',   TranslationIO.config.pot_copyright_holder,
                                       '--copyright-year',     TranslationIO.config.pot_copyright_year.to_s)

          params["pot_data"] = File.read(@pot_path)
        end
      end
    end
  end
end
