require 'translation/yaml_conversion/flat'

module Translation
  module YAMLConversion
    class << self

      def get_pot_data_from_yaml(source_locale = nil, yaml_file_paths = nil)
        source_locale   = Translation.config.source_locale if source_locale.blank?
        yaml_file_paths = I18n.load_path                   if yaml_file_paths.nil?

        source_translations = Flat.get_flat_translations_for_locale(source_locale, yaml_file_paths)
        pot_representation  = GetText::PO.new

        source_translations.each_pair do |key, value|
          msgid = value

          unless msgid.blank?
            pot_entry            = GetText::POEntry.new(:msgctxt)
            pot_entry.msgid      = msgid
            pot_entry.msgctxt    = key.split('.', 2).last
            #pot_entry.references = [ value[:locale_file_path] ]

            pot_representation[ pot_entry.msgctxt, pot_entry.msgid ] = pot_entry
          end
        end

        pot_representation.to_s
      end

      def get_yaml_data_from_po_data(po_data, target_locale)
        parser            = GetText::POParser.new
        po_representation = GetText::PO.new
        flat_translations = {}

        parser.parse(po_data, po_representation)

        po_representation.each do |po_entry|
          flat_translations["#{target_locale}.#{po_entry.msgctxt}"] = po_entry.msgstr
        end

        translations = YAMLConversion::Flat.get_yaml_data_from_flat_translations(flat_translations)

        return translations
      end

    end
  end
end
