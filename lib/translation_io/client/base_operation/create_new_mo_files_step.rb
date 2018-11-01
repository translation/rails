module TranslationIO
  class Client
    class BaseOperation
      class CreateNewMoFilesStep
        def initialize(locales_path)
          @locales_path = locales_path
        end

        def run
          TranslationIO.info "Creating new MO files."

          Dir["#{@locales_path}/*/#{TranslationIO.config.text_domain}.po"].each do |po_path|
            mo_path = "#{File.dirname(po_path)}/LC_MESSAGES/#{TranslationIO.config.text_domain}.mo"
            TranslationIO.info mo_path, 2, 2
            FileUtils.mkdir_p(File.dirname(mo_path))
            GetText::Tools::MsgFmt.run(po_path, '-o', mo_path)
          end
        end
      end
    end
  end
end
