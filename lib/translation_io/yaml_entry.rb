module TranslationIO
  module YamlEntry

    IGNORED_KEY_PREFIXES = [
      'faker'
    ]

    LOCALIZATION_KEY_PREFIXES = [
      'date.formats',
      'date.order',
      'time.formats',
      'support.array',
      'number.format',
      'number.currency',
      'number.percentage',
      'number.precision',
      'number.human.format',
      'number.human.storage_units.format',
      'number.human.decimal_units.format',
      'number.human.decimal_units.units.unit',
      'i18n.transliterate'
    ]

    class << self
      def string?(key, value)
        key.present? && value.is_a?(String)
      end

      def from_locale?(key, locale)
        key.present? && key.start_with?("#{locale}.")
      end

      def ignored?(key)
        key.present? && ignored_key_prefixes.any? { |prefix| ignored_prefix?(key, prefix) || ignored_regex?(key, prefix) }
      end

      def localization?(key, value)
        key.present? && (localization_prefix?(key) || (!string?(key, value) && !value.nil?))
      end

      def localization_prefix?(key)
        localization_key_prefixes.any? { |prefix| key_without_locale(key).match(/^#{Regexp.escape(prefix)}\b/) != nil }
      end

      private

      def ignored_prefix?(key, prefix)
        if prefix.is_a?(String)
          regex = /^#{Regexp.escape(prefix)}\b/
          key_without_locale(key).match(regex) != nil
        else
          false
        end
      end

      def ignored_regex?(key, regex)
        if regex.is_a?(Regexp)
          key_without_locale(key).match(regex) != nil
        else
          false
        end
      end

      def localization_key_prefixes
        if TranslationIO.config
          LOCALIZATION_KEY_PREFIXES + TranslationIO.config.localization_key_prefixes
        else
          LOCALIZATION_KEY_PREFIXES
        end
      end

      def ignored_key_prefixes
        if TranslationIO.config
          IGNORED_KEY_PREFIXES + TranslationIO.config.ignored_key_prefixes
        else
          IGNORED_KEY_PREFIXES
        end
      end

      def key_without_locale(key)
        key.split('.', 2).last
      end
    end
  end
end
