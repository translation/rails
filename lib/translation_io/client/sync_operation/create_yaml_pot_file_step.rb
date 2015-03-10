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

          all_translations = {}

          @yaml_file_paths.each do |file_path|
            TranslationIO.info file_path, 2, 2
            file_translations = YAML::load(File.read(file_path))

            unless file_translations.blank?
              all_translations = all_translations.deep_merge(file_translations)
            end
          end

          all_flat_translations = FlatHash.to_flat_hash(all_translations)

          source_flat_string_tanslations = all_flat_translations.select do |key, value|
            YamlEntry.string?(key, value) && YamlEntry.from_locale?(key, @source_locale) && !YamlEntry.ignored?(key) && !YamlEntry.localization?(key, value)
          end

          pot_representation = GetText::PO.new

          source_flat_string_tanslations.each_pair do |key, value|
            msgid = value

            unless msgid.to_s.empty?
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
