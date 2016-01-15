module TranslationIO
  module Content
    class Init
      def run
        po_representations = {}
        storage            = TranslationIO::Content.storage
        source_locale      = TranslationIO::Content.config.source_locale

        TranslationIO::Content.config.target_locales.each do |target_locale|
          po_representations[target_locale] = GetText::PO.new
        end

        TranslationIO::Content.translated_fields.each_pair do |class_name, field_names|
          puts "* #{class_name}"

          class_name.constantize.find_each do |instance|
            puts "  * #{instance.id}"

            field_names.each do |field_name|
              puts "    * #{field_name}"

              msgid = storage.get(source_locale, instance, field_name)

              TranslationIO::Content.config.target_locales.each do |target_locale|
                puts "      * #{target_locale}"

                unless msgid.to_s.empty?
                  po_entry         = GetText::POEntry.new(:msgctxt)
                  po_entry.msgid   = msgid
                  po_entry.msgstr  = storage.get(target_locale, instance, field_name)
                  po_entry.msgctxt = "#{class_name}-#{instance.id}-#{field_name}"

                  po_representations[target_locale][po_entry.msgctxt, po_entry.msgid] = po_entry
                end
              end
            end
          end
        end

        params = {}

        po_representations.each_pair do |target_locale, po_representation|
          params["content_po_data_#{target_locale}"] = po_representation.to_s
        end

        TranslationIO.info "Sending content data to server"
        uri             = URI("#{TranslationIO::Content.config.endpoint}/projects/#{TranslationIO::Content.config.api_key}/content_init")
        parsed_response = TranslationIO::Content.perform_request(uri, params)

        puts "Init content success."
      end
    end
  end
end
