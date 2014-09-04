module YamlEntry
  class << self
    def string?(key, value)
      key.present? && value.is_a?(String)
    end

    def from_locale?(key, locale)
      key.present? && key.start_with?("#{locale}.")
    end

    def ignored?(key, locale)
      key.present? && key_without_locale(key).start_with?("faker.")
    end

    def localization?(key, value)
      key.present? && (['date.order[0]', 'date.order[1]', 'date.order[2]'].include?(key_without_locale(key)) || (!YamlEntry.string?(key, value) && !value.nil?))
    end

    private

    def key_without_locale(key)
      key.split('.', 2).last
    end
  end
end
