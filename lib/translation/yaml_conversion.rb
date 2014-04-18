require 'translation/yaml_conversion/flat'

module Translation
  module YAMLConversion
    class << self

      def get_pot_data_from_yaml
        source_translations = Flat.get_flat_translations_for_locale(Translation.config.source_locale)
        pot_representation  = GetText::PO.new

        source_translations.each_pair do |key, value|
          msgid = value[:translation]

          unless msgid.blank?
            pot_entry            = GetText::POEntry.new(:msgctxt)
            pot_entry.msgid      = msgid
            pot_entry.msgctxt    = key
            pot_entry.references = [ value[:locale_file_path] ]

            pot_representation[pot_entry.msgctxt, pot_entry.msgid] = pot_entry
          end
        end

        pot_representation.to_s
      end

      def get_yaml_data_from_po_data(po_data)
        parser            = GetText::POParser.new
        po_representation = GetText::PO.new
        flat_translations = {}
        translations      = {}

        parser.parse(po_data, po_representation)

        po_representation.each do |po_entry|
          flat_translations[po_entry.msgctxt] = po_entry.msgstr
        end

        flat_translations.each_pair do |key, value|
          key_parts = key.split('.')

          acc = translations

          key_parts.each_with_index do |key_part, index|
            if index < key_parts.size - 1
              acc[key_part] = {} unless acc.has_key?(key_part)
              acc = acc[key_part]
            else
              acc[key_part] = value
            end
          end
        end

        return translations.to_yaml
      end

    end
  end
end
