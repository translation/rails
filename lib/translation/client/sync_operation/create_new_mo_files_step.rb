module Translation
  class Client
    class SyncOperation < BaseOperation
      class CreateNewMoFilesStep
        def initialize(locales_path)
          @locales_path = locales_path
        end

        def run
          Translation.info "Creating new MO files."

          Dir["#{@locales_path}/*/app.po"].each do |po_path|
            mo_path = "#{File.dirname(po_path)}/LC_MESSAGES/app.mo"
            Translation.info mo_path, 2
            FileUtils.mkdir_p(File.dirname(mo_path))
            GetText::Tools::MsgFmt.run(po_path, '-o', mo_path)
          end
        end
      end
    end
  end
end
