require 'i18n'
require 'i18n/config'
require "i18n/backend/fallbacks"

module TranslationIO
  class Railtie < Rails::Railtie
    rake_tasks do
      require 'translation_io/tasks'
    end

    initializer 'translation.controller_helper' do
      ActiveSupport.on_load :action_controller do
        ActionController::Base.send(:include, TranslationIO::Controller)
      end
    end

    config.after_initialize do
      # Ensure GetText.locale is in sync with I18n's default locale at boot
      I18n.locale = I18n.default_locale
    end
  end
end

###
# Set GetText/Locale current locale based on I18n.locale
###
module I18nConfigExtension
  def locale=(*args)
    super

    if defined? Locale
      # GetText/Locale already uses default fallbacks ("en-us-custom" => "en-us" => "en-custom" => "en")
      # But we want to add them custom fallbacks from I18n (ex:  "fr" => "nl" => "en")
      # cf. https://github.com/translation/rails/issues/48
      fallback_locales = I18n.fallbacks[I18n.locale].collect { |l| l.to_s.gsub('-', '_').to_sym }

      Locale.set_current(*fallback_locales)
    end
  end
end

I18n::Config.prepend I18nConfigExtension

###
# Monkey-Patch GetText to :
#  * Ignore GetText warnings
#  * Don't stop code parsing if a file is badly formatted + message
###
if defined? GetText
  module GetText
    class POParser < Racc::Parser
      def initialize
        @ignore_fuzzy   = true
        @report_warning = false
      end
    end

    module Tools
      class XGetText
        def parse(paths)
          po = PO.new
          paths = [paths] if paths.kind_of?(String)
          paths.each do |path|
            begin
              parse_path(path, po)
            rescue SystemExit => e
              puts
              puts "---------------"
              puts "Error while parsing this file for GetText: #{path}"
              puts "Are you sure the file is correctly formatted?"
              puts "Feel free to contact us to get some help: contact@translation.io"
              puts "---------------"
              puts
            end
          end
          po
        end
      end
    end
  end
end
