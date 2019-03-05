require 'net/http'

module TranslationIO
  GETTEXT_METHODS = [
    :nsgettext, :pgettext, :npgettext, :sgettext, :ngettext, :gettext,
    :np_, :ns_, :Nn_, :n_, :p_, :s_, :N_, :_
  ]

  TEXT_DOMAIN = 'app'
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
    attr_reader :config
    attr_accessor :client

    def configure(&block)
      ENV['LANG'] = 'en_US.UTF-8' if ENV['LANG'].blank?

      @config ||= Config.new

      yield @config

      # setup for default config (aka should work the same but avoid app/views/branded)
      @config.set_domain(@config.domains.nil? ? nil : @config.domains.first)

      unless @config.disable_gettext
        require_gettext_dependencies
        add_missing_locales
        add_parser_for_erb_source_formats(@config.erb_source_formats)

        if Rails.env.development?
          GetText::TextDomainManager.cached = false
        end

        # include is private until Ruby 2.1
        Proxy.send(:include, GetText)

        if @config.domains.nil?
          Proxy.bindtextdomain(@config.text_domain, {
            :path           => @config.locales_path,
            :output_charset => @config.charset
          })
        else
          @config.domains.each do |domain|
            Proxy.bindtextdomain(domain[:name], {
              path: @config.locales_path,
              output_charset: @config.charset
              })
          end
        end

        Proxy.textdomain(@config.text_domain)
        Object.delegate *GETTEXT_METHODS, :to => Proxy
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
    end

    # Missing languages from Locale that are in Translation.io
    def add_missing_locales
      Locale::Info.three_languages['wee'] = Locale::Info::Language.new('', 'wee', 'I', 'L', 'Lower Sorbian')
      Locale::Info.three_languages['wen'] = Locale::Info::Language.new('', 'wen', 'I', 'L', 'Upper Sorbian')
    end

    def add_parser_for_erb_source_formats(new_erb_formats)
      existing_extensions = GetText::ErbParser.instance_variable_get("@config")[:extnames]
      new_extensions = new_erb_formats.collect { |ext| ".#{ext}" }

      GetText::ErbParser.instance_variable_get("@config")[:extnames] = (existing_extensions + new_extensions).uniq
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

    def version
      Gem::Specification::find_by_name('translation').version.to_s
    end
  end
end
