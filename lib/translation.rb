require 'net/http'

module TranslationIO
  GETTEXT_METHODS = [
    :nsgettext, :pgettext, :npgettext, :sgettext, :ngettext, :gettext,
    :np_, :ns_, :Nn_, :n_, :p_, :s_, :N_, :_
  ]
end

require 'translation_io/config'
require 'translation_io/railtie'
require 'translation_io/client'
require 'translation_io/flat_hash'
require 'translation_io/yaml_conversion'

require 'translation_io/controller'
require 'translation_io/extractor'
require 'translation_io/yaml_entry'

module TranslationIO
  module Proxy
  end

  class << self
    attr_reader :config, :client

    def configure(&block)
      ENV['LANG'] = 'en_US.UTF-8' if ENV['LANG'].blank?

      @config ||= Config.new

      yield @config

      if !@config.disable_gettext
        require_gettext_dependencies
        add_parser_for_erb_source_formats(@config.erb_source_formats)

        if Rails.env.development?
          GetText::TextDomainManager.cached = false
        end

        # Set default GetText locale (last fallback) as config.source_locale instead of "en" (default)
        gettext_locale = @config.source_locale.to_s.gsub('-', '_').to_sym
        Locale.set_default(gettext_locale)

        # include is private until Ruby 2.1
        Proxy.send(:include, GetText)

        @config.bound_text_domains.each do |bound_text_domain|
          Proxy.bindtextdomain(bound_text_domain, {
            :path           => @config.locales_path,
            :output_charset => @config.charset
          })
        end

        Proxy.textdomain(@config.text_domain)

        if @config.gettext_object_delegate
          Object.delegate *GETTEXT_METHODS, :to => Proxy
        end
      end

      @client = Client.new(@config.api_key, @config.endpoint)

      return true
    end

    def require_gettext_dependencies
      require 'gettext'
      require 'gettext/po'
      require 'gettext/po_parser'
      require 'gettext/tools'
      require 'gettext/text_domain_manager'
      require 'gettext/tools/xgettext'
      require "gettext/tools/parser/erubi" if Gem::Version.new(GetText::VERSION) >= Gem::Version.new('3.4.3')
    end

    def add_parser_for_erb_source_formats(new_erb_formats)
      new_extensions = new_erb_formats.collect { |ext| ".#{ext}" }

      existing_extensions = GetText::ErbParser.instance_variable_get("@config")[:extnames]
      GetText::ErbParser.instance_variable_get("@config")[:extnames] = (existing_extensions + new_extensions).uniq

      # for gettext >= 3.4.3 (erubi compatibility)
      if defined?(GetText::ErubiParser)
        existing_extensions = GetText::ErubiParser.instance_variable_get("@config")[:extnames]
        GetText::ErubiParser.instance_variable_get("@config")[:extnames] = (existing_extensions + new_extensions).uniq
      end
    end

    def info(message, level = 0, verbose_level = 0)
      verbose = @config.try(:verbose) || 0
      if verbose >= verbose_level
        indent = (1..level).to_a.collect { "   " }.join('')
        puts "#{indent}* #{message}"
      end
    end

    def normalize_path(relative_or_absolute_path)
      File.expand_path(relative_or_absolute_path).gsub("#{Dir.pwd}/", '')
    end

    # Cf. https://github.com/translation/rails/issues/47
    def yaml_load(source)
      begin
        YAML.load(source, :aliases => true) || {}
      rescue ArgumentError
        YAML.load(source) || {}
      end
    end

    def version
      Gem::Specification::find_by_name('translation').version.to_s
    end
  end
end
