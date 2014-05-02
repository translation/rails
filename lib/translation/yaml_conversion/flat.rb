module Translation
  module YAMLConversion
    module Flat
      class << self

        def get_flat_translations_for_locale(locale, yaml_file_paths = nil)
          yaml_file_paths = I18n.load_path if yaml_file_paths.blank?

          all_flat_translations = {}

          yaml_file_paths.each do |yaml_file_path|
            content      = File.read(yaml_file_path)
            translations = YAML::load(content)

            if translations.has_key?(locale.to_s)
              flat_translations = FlatHash.to_flat_hash(translations)
              all_flat_translations.merge!(flat_translations)
            end
          end

          return all_flat_translations
        end

        def get_flat_translations_for_yaml_file(file_path)
          yaml_data = File.read(file_path)
          return get_flat_translations_for_yaml_data(yaml_data)
        end

        def get_flat_translations_for_yaml_data(yaml_data)
          translations = YAML::load(yaml_data)
          return FlatHash.to_flat_hash(translations)
        end

        def get_yaml_data_from_flat_translations(flat_translations)
          translations = FlatHash.to_hash(flat_translations)
          return translations.to_yaml
        end

      end
    end
  end
end
