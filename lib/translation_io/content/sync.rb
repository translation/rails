module TranslationIO
  module Content
    class Sync
      def run
        storage        = TranslationIO::Content.storage
        source_locale  = TranslationIO::Content.config.source_locale
        target_locales = TranslationIO::Content.config.target_locales

        # appel pour avoir les source edits depuis une date

        uri                   = URI("#{TranslationIO::Content.config.endpoint}/projects/#{TranslationIO::Content.config.api_key}/content_source_edits")
        source_edits_response = TranslationIO::Content::Request.new(uri).perform

        # appliquer les changements de source reçus (ignorer un changement si ça a changé en DB depuis)

        source_edits_response['content_source_edits'].each do |source_edit|
          old_text    = source_edit['old_text']
          new_text    = source_edit['new_text']
          key         = source_edit['key']
          key_parts   = key.split('-')
          class_name  = key_parts.first
          instance_id = key_parts.second.to_i
          field_name  = key_parts.last
          instance    = class_name.constantize.find(instance_id)

          if storage.get(source_locale, instance, field_name) == old_text
            TranslationIO.info "#{key} | #{old_text} -> #{new_text}"
            storage.set(source_locale, instance, field_name, new_text)
          else
            puts "Ignore #{key}"
          end
        end

        # chopper tous les changements/ajouts *de source* en DB et les envoyer à content_sync en backend

        last_content_synced_at = Time.at(source_edits_response['last_content_synced_at'].to_i)
        pot_representation     = GetText::PO.new

        TranslationIO::Content.translated_fields.each_pair do |class_name, field_names|
          puts "* #{class_name}"

          class_name.constantize.where('updated_at > ?', last_content_synced_at).find_each do |instance|
            puts "  * #{instance.id}"

            field_names.each do |field_name|
              puts "    * #{field_name}"

              msgid = storage.get(source_locale, instance, field_name)

              unless msgid.to_s.empty?
                po_entry         = GetText::POEntry.new(:msgctxt)
                po_entry.msgid   = msgid
                po_entry.msgstr  = ""
                po_entry.msgctxt = "#{class_name}-#{instance.id}-#{field_name}"

                pot_representation[po_entry.msgctxt, po_entry.msgid] = po_entry
              end
            end
          end
        end

        params = {}
        params["content_pot_data"] = pot_representation.to_s

        uri           = URI("#{TranslationIO::Content.config.endpoint}/projects/#{TranslationIO::Content.config.api_key}/content_sync")
        sync_response = TranslationIO::Content::Request.new(uri, params).perform

        puts sync_response

        # traiter la réponse du backend qui contient éventuellement des nouvelles traductions : appliquer ces traductions en DB

        target_locales.each do |target_locale|
          po_data = sync_response["content_po_data_#{target_locale}"]

          unless po_data.blank?
            parser            = GetText::POParser.new
            po_representation = GetText::PO.new

            parser.parse(po_data, po_representation)

            po_representation.each do |po_entry|
              key_parts   = po_entry.msgctxt.split('-')
              class_name  = key_parts.first
              instance_id = key_parts.second.to_i
              field_name  = key_parts.last
              instance    = class_name.constantize.find(instance_id)
              new_value   = po_entry.msgstr.to_s

              storage.set(target_locale, instance, field_name, new_value)
            end
          end
        end
      end
    end
  end
end
