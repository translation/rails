module Translation
  module YAMLConversion
    module Flat
      class << self
        def get_flat_translations_for_locale(locale)
          flat_translations = {}

          I18n.load_path.each do |load_path|
            content           = File.read(load_path)
            translations      = YAML::load(content)

            if translations.has_key?(locale.to_s)
              flat_translations.merge!(
                get_flat_translations_for_level(translations[locale.to_s])
              )
            end
          end

          flat_translations
        end

        private

        def get_flat_translations_for_level(translations, parent_key = nil)
          flat_translations = {}

          translations.each_pair do |key, value|
            current_level_key = [ parent_key, key ].reject(&:blank?).join('.')

            if value.is_a? Hash
              flat_translations.merge!(
                get_flat_translations_for_level(value, current_level_key)
              )
            elsif value.is_a? String
              flat_translations[current_level_key] = value
            else
              # TODO : Boolean, Array, Integer
              {}
            end
          end

          flat_translations
        end
      end
    end

    class << self
      def get_pot_data_from_yaml
        source_translations = Flat.get_flat_translations_for_locale(Translation.config.source_locale)

        # POT file

        pot_representation = GetText::PO.new
        pot_path           = File.join(Translation.config.locales_path, 'yaml.pot')

        source_translations.each_pair do |key, value|
          msgid = value

          unless msgid.blank?
            pot_entry         = GetText::POEntry.new(:normal)
            pot_entry.msgid   = msgid
            pot_entry.comment = key

            pot_representation[pot_entry.msgctxt, pot_entry.msgid] = pot_entry
          end
        end

        File.open(pot_path, 'w') do |f|
          f.write(pot_representation.to_s)
        end

        # PO files

        Translation.config.target_locales.each do |locale|
          po_representation   = GetText::PO.new
          target_translations = Flat.get_flat_translations_for_locale(locale)
          po_path             = File.join(Translation.config.locales_path, locale.to_s, 'yaml.po')

          target_translations.each_pair do |key, value|
            msgid = source_translations[key]

            unless msgid.blank?
              po_entry         = GetText::POEntry.new(:normal)
              po_entry.msgid   = msgid # TODO : msgidplural, msgctxt
              po_entry.msgstr  = value
              po_entry.comment = key

              po_representation[po_entry.msgctxt, po_entry.msgid] = po_entry
            end
          end

          File.open(po_path, 'w') do |f|
            f.write(po_representation.to_s)
          end
        end
      end
    end

  end
end
