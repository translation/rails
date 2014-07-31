require 'i18n'
require 'i18n/config'

require 'gettext'
require 'gettext/po'
require 'gettext/po_parser'

module TranslationIO
  class Railtie < Rails::Railtie
    rake_tasks do
      require 'translation_io/tasks'
    end

    initializer 'translation.rails_extensions' do
      ActionController::Base.send(:include, TranslationIO::Controller)
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

module GetText
  class POParser < Racc::Parser
    def initialize
      @ignore_fuzzy   = true
      @report_warning = false
    end
  end
end
