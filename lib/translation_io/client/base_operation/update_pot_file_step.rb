module TranslationIO
  class Client
    class BaseOperation
      class UpdatePotFileStep
        def initialize(pot_path, source_files)
          @pot_path = pot_path

          if TranslationIO.config.disable_gettext
            @source_files = empty_source_files
          else
            @source_files = source_files + Dir['tmp/translation/*.rb']
          end
        end

        def run(params)
          TranslationIO.info "Updating POT file."

          FileUtils.mkdir_p(File.dirname(@pot_path))

          # for gettext >= 3.4.3 (erubi compatibility)
          if defined?(GetText::ErubiParser)
            GetText::Tools::XGetText.run(
              *@source_files, '-o', @pot_path,
              '--msgid-bugs-address', TranslationIO.config.pot_msgid_bugs_address,
              '--package-name',       TranslationIO.config.pot_package_name,
              '--package-version',    TranslationIO.config.pot_package_version,
              '--copyright-holder',   TranslationIO.config.pot_copyright_holder,
              '--copyright-year',     TranslationIO.config.pot_copyright_year.to_s,
              '--require',            'gettext/tools/parser/erubi', # Cf. (1) https://github.com/ruby-gettext/gettext/pull/91
              '--parser',             'GetText::ErubiParser'        #     (2) https://github.com/ruby-gettext/gettext/commit/0eb06a88323a5cc16065680ffe228d978fb87c88
            )
          else
            GetText::Tools::XGetText.run(
              *@source_files, '-o', @pot_path,
              '--msgid-bugs-address', TranslationIO.config.pot_msgid_bugs_address,
              '--package-name',       TranslationIO.config.pot_package_name,
              '--package-version',    TranslationIO.config.pot_package_version,
              '--copyright-holder',   TranslationIO.config.pot_copyright_holder,
              '--copyright-year',     TranslationIO.config.pot_copyright_year.to_s
            )
          end

          FileUtils.rm_f(@tmp_empty_file) if @tmp_empty_file.present?

          params['pot_data'] = File.read(@pot_path)
        end

        private

        def empty_source_files
          @tmp_empty_file = 'tmp/empty-gettext-file.rb'
          FileUtils.mkdir_p('tmp')
          FileUtils.touch(@tmp_empty_file)

          [@tmp_empty_file]
        end
      end
    end
  end
end
