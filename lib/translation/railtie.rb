require 'i18n'
require 'i18n/config'

module Translation
  class Railtie < Rails::Railtie
    rake_tasks do
      require 'translation/tasks'
    end
  end
end

module I18n
  class Config
    def locale=(locale)
      I18n.enforce_available_locales!(locale)
      @locale        = locale.to_sym rescue nil
      GetText.locale = locale.to_s.gsub('-', '_').to_sym
    end
  end
end
