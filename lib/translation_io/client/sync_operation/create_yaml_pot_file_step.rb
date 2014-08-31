module TranslationIO
  class Client
    class SyncOperation < BaseOperation
      class CreateYamlPotFileStep
        def initialize(source_locale, yaml_file_paths)
          @source_locale   = source_locale
          @yaml_file_paths = yaml_file_paths
        end

        def run(params)
          TranslationIO.info "Generating POT file from YAML files."
          all_flat_translations  = {}

          @yaml_file_paths.each do |file_path|
            TranslationIO.info file_path, 2, 2
            all_flat_translations.merge!(
              YAMLConversion.get_flat_translations_for_yaml_file(file_path)
            )
          end

          source_flat_string_tanslations = all_flat_translations.select do |key, value|
            value.is_a?(String) && key.present? && key.start_with?("#{@source_locale}.") && !key.start_with?("#{@source_locale}.faker.")
          end

          pot_representation = GetText::PO.new

          source_flat_string_tanslations.each_pair do |key, value|
            msgid = value

            unless msgid.blank?
              pot_entry            = GetText::POEntry.new(:msgctxt)
              pot_entry.msgid      = msgid
              pot_entry.msgstr     = ''
              pot_entry.msgctxt    = key.split('.', 2).last
              #pot_entry.references = [ value[:locale_file_path] ]

              pot_representation[pot_entry.msgctxt, pot_entry.msgid] = pot_entry
            end
          end

          params['yaml_pot_data'] = pot_representation.to_s
        end
      end
    end
  end
end
