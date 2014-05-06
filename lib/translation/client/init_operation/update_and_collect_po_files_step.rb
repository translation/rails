module Translation
  class Client
    class InitOperation < BaseOperation
      class UpdateAndCollectPoFilesStep
        attr_reader :params

        def initialize(target_locales, pot_path, locales_path)
          @target_locales = target_locales
          @pot_path       = pot_path
          @locales_path   = locales_path
          @params         = {}
        end

        def run
          Translation.info "Updating PO files."

          @target_locales.each do |target_locale|
            po_path = "#{@locales_path}/#{target_locale}/app.po"
            Translation.info po_path, 2

            if File.exist?(po_path)
              GetText::Tools::MsgMerge.run(po_path, @pot_path, '-o', po_path)
            else
              FileUtils.mkdir_p(File.dirname(po_path))
              FileUtils.copy(@pot_path, po_path)
            end

            @params["po_data_#{target_locale}"] = File.read(po_path)
          end

          return self
        end
      end
    end
  end
end
