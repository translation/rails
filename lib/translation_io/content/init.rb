module TranslationIO
  module Content
    class Init
      def run
        uri = URI("#{TranslationIO::Content.config.endpoint}/projects/#{TranslationIO::Content.config.api_key}/content_init")
        TranslationIO::Content::Request.new(uri, build_init_params).perform
        return true
      end

      def build_init_params
        po_representations = {}
        storage            = TranslationIO::Content.storage
        source_locale      = TranslationIO::Content.config.source_locale

        TranslationIO::Content.config.target_locales.each do |target_locale|
          po_representations[target_locale] = GetText::PO.new
        end

        TranslationIO::Content.translated_fields.each_pair do |class_name, field_names|
          class_name.constantize.find_each do |instance|
            field_names.each do |field_name|
              msgid = storage.get(source_locale, instance, field_name)

              TranslationIO::Content.config.target_locales.each do |target_locale|
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

        params
      end
    end
  end
end
