module TranslationIO
  class Client
    class InitOperation < BaseOperation
      class CreateYamlPoFilesStep
        attr_accessor :all_used_yaml_locales

        def initialize(source_locale, target_locales, yaml_file_paths)
          @source_locale         = source_locale
          @target_locales        = target_locales
          @yaml_file_paths       = yaml_file_paths
          @all_used_yaml_locales = Set.new
        end

        def run(params)
          TranslationIO.info "Importing translations from YAML files."

          all_translations = {}

          @yaml_file_paths.each do |file_path|
            TranslationIO.info file_path, 2, 2
            file_translations = TranslationIO.yaml_load(File.read(file_path))

            unless file_translations.blank?
              all_translations = all_translations.deep_merge(file_translations)
            end
          end

          all_flat_translations = FlatHash.to_flat_hash(all_translations)

          all_flat_string_translations = all_flat_translations.select do |key, value|
            all_used_yaml_locales << key.split('.').first
            YamlEntry.string?(key, value) && !YamlEntry.localization?(key, value)
          end

          source_flat_string_translations = all_flat_string_translations.select do |key|
            YamlEntry.from_locale?(key, @source_locale) && !YamlEntry.ignored?(key)
          end

          @target_locales.each do |target_locale|
            po_representation = GetText::PO.new

            source_flat_string_translations.each_pair do |key, value|
              target_key = key.gsub(/\A#{TranslationIO.config.source_locale}\./, "#{target_locale}.")
              msgid      = value
              msgstr     = all_flat_string_translations[target_key]

              unless msgid.to_s.empty?
                po_entry            = GetText::POEntry.new(:msgctxt)
                po_entry.msgid      = msgid
                po_entry.msgstr     = msgstr
                po_entry.msgctxt    = key.split('.', 2).last
                #po_entry.references = [ value[:locale_file_path] ]

                po_representation[po_entry.msgctxt, po_entry.msgid] = po_entry
              end
            end

            params["yaml_po_data_#{target_locale}"] = po_representation.to_s
          end
        end
      end
    end
  end
end
