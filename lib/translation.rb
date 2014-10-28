require 'net/http'

require 'gettext'
require 'gettext/po'
require 'gettext/po_parser'
require 'gettext/tools'
require 'gettext/text_domain_manager'

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
    include GetText
  end

  class << self
    attr_reader :config, :client

    def configure(&block)
      ENV['LANG']     = 'en_US.UTF-8' if ENV['LANG'].blank?
      ENV['LC_CTYPE'] = 'UTF-8'       if ENV['LC_CTYPE'].blank?

      if Rails.env.development?
        GetText::TextDomainManager.cached = false
      end

      @config ||= Config.new

      yield @config

      Proxy.bindtextdomain(TEXT_DOMAIN, {
        :path           => @config.locales_path,
        :output_charset => @config.charset
      })

      Proxy.textdomain(TEXT_DOMAIN)
      Object.delegate *GETTEXT_METHODS, :to => Proxy

      @client = Client.new(@config.api_key, @config.endpoint)

      return true
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
