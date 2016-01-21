module TranslationIO
  module Content
    class Sync
      attr_reader :storage, :source_locale, :target_locales

      def initialize
        @storage        = TranslationIO::Content.storage
        @source_locale  = TranslationIO::Content.config.source_locale
        @target_locales = TranslationIO::Content.config.target_locales
      end

      def run
        source_edits_response = get_source_edits_from_backend
        apply_source_edits(source_edits_response)

        backend_response = submit_local_changes_to_backend(
          build_local_changes_params(
            source_edits_response['last_content_synced_at'].to_i
          )
        )

        apply_new_translations_from_backend(backend_response)
        touch_last_content_synced_at_on_backend
        true
      end

      def get_source_edits_from_backend
        uri = URI("#{TranslationIO::Content.config.endpoint}/projects/#{TranslationIO::Content.config.api_key}/content_source_edits")
        return TranslationIO::Content::Request.new(uri).perform
      end

      def apply_source_edits(data)
        data['content_source_edits'].each do |source_edit|
          old_text    = source_edit['old_text']
          new_text    = source_edit['new_text']
          key         = source_edit['key']
          key_parts   = key.split('-')
          class_name  = key_parts.first
          instance_id = key_parts.second.to_i
          field_name  = key_parts.last
          instance    = class_name.constantize.find_by_id(instance_id)

          if instance.present?
            if storage.get(source_locale, instance, field_name) == old_text
              #puts "#{key} | #{old_text} -> #{new_text}"
              storage.set(source_locale, instance, field_name, new_text)
            else
              #puts "Ignore #{key}"
            end
          end
        end
      end

      def build_local_changes_params(last_content_synced_at)
        last_content_synced_at = Time.at(last_content_synced_at)
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

        return {
          "content_pot_data" => pot_representation.to_s
        }
      end

      def submit_local_changes_to_backend(params)
        uri = URI("#{TranslationIO::Content.config.endpoint}/projects/#{TranslationIO::Content.config.api_key}/content_sync")
        return TranslationIO::Content::Request.new(uri, params).perform
      end

      def apply_new_translations_from_backend(response)
        target_locales.each do |target_locale|
          po_data = response["content_po_data_#{target_locale}"]

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

              if instance.present?
                storage.set(target_locale, instance, field_name, new_value)
              end
            end
          end
        end
      end

      def touch_last_content_synced_at_on_backend
        uri = URI("#{TranslationIO::Content.config.endpoint}/projects/#{TranslationIO::Content.config.api_key}/content_touch_last_content_synced_at")
        return TranslationIO::Content::Request.new(uri).perform
      end
    end
  end
end
