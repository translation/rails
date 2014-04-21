module Translation
  module YAMLConversion
    module Flat
      class << self
        def get_flat_translations_for_locale(locale)
          flat_translations = {}

          I18n.load_path.each do |locale_file_path|
            content           = File.read(locale_file_path)
            translations      = YAML::load(content)

            if translations.has_key?(locale.to_s)
              flat_translations.merge!(
                get_flat_translations_for_level(translations[locale.to_s], locale_file_path)
              )
            end
          end

          flat_translations
        end

        def get_flat_translations_for_yaml_file(file_path)
          content      = File.read(file_path)
          translations = YAML::load(content)
          return get_flat_translations_for_level(translations, file_path)
        end

        # def get_yaml_from_flat_yaml(flat_translations)
        #   translations = {}

        #   flat_translations.each_pair do |key, value|
        #     key_parts = key.split('.')

        #     acc = translations

        #     key_parts.each_with_index do |key_part, index|
        #       if index < key_parts.size - 1
        #         unless acc.has_key?(key_part)
        #           acc[key_part] = {}
        #         end

        #         acc = acc[key_part]
        #       else
        #         if key_part.end_with?(']')
        #           key_part_prefix = key_part.split('[').first
        #           item_index      = key_part.split('[').last.to_i

        #           unless acc.has_key?(key_part_prefix)
        #             acc[key_part_prefix] = []
        #           end

        #           acc[key_part_prefix][item_index] = value
        #         else
        #           acc[key_part] = value
        #         end
        #       end
        #     end
        #   end

        #   return translations.to_yaml
        # end

        def get_yaml_from_flat_yaml(flat_translations)
          translations = {}

          flat_translations.each_pair do |key, value|
            key_parts = key.split('.')

            acc = translations

            key_parts.each_with_index do |key_part, index|
              if index < key_parts.size - 1
                unless acc.has_key?(key_part)
                  acc[key_part] = {}
                end

                acc = acc[key_part]
              else
                if key_part.end_with?(']')
                  key_part_prefix = key_part.split('[').first
                  item_index      = key_part.split('[').last.to_i

                  unless acc.has_key?(key_part_prefix)
                    acc[key_part_prefix] = []
                  end

                  acc[key_part_prefix][item_index] = value
                else
                  acc[key_part] = value
                end
              end
            end
          end

          return translations.to_yaml
        end

        private

        def get_flat_translations_for_level(translations, locale_file_path, parent_key = nil)
          flat_translations = {}

          translations.each_pair do |key, value|
            current_level_key = [ parent_key, key ].reject(&:blank?).join('.')

            if value.is_a? Hash
              flat_translations.merge!(
                get_flat_translations_for_level(value, locale_file_path, current_level_key)
              )
            elsif value.is_a? Array
              value.each_with_index do |item, index|
                flat_translations["#{current_level_key}[#{index}]"] = {
                  :locale_file_path => locale_file_path,
                  :translation      => item.to_s
                }
              end
            else
              flat_translations[current_level_key] = {
                :locale_file_path => locale_file_path,
                :translation      => value
              }
            end
          end

          flat_translations
        end
      end
    end
  end
end
