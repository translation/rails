require 'net/http'

require 'gettext'
require 'gettext/po'
require 'gettext/po_parser'
require 'gettext/tools'
require 'gettext/text_domain_manager'

module Translation
  GETTEXT_METHODS = [
    :_, :n_, :p_, :s_, :np_, :ns_, :N_, :Nn,
    :gettext, :sgettext, :ngettext, :nsgettext, :pgettext, :npgettext
  ]

  TEXT_DOMAIN          = 'app'
  SOURCE_FILES_PATTERN = '**/*.{rb,erb,html.erb,xml.erb}'
end

require 'translation/config'
require 'translation/railtie'
require 'translation/client'
require 'translation/flat_hash'
require 'translation/yaml_conversion'

require 'translation/controller'

module Translation
  module Proxy
    include GetText
  end

  class << self
    attr_reader :config, :client

    def configure(&block)
      if Rails.env.development?
        GetText::TextDomainManager.cached = false
      end

      @config ||= Config.new

      yield @config

      Proxy.bindtextdomain(TEXT_DOMAIN, {
        :path    => @config.locales_path,
        :charset => 'utf-8'
      })

      Proxy.textdomain(TEXT_DOMAIN)
      Object.delegate *GETTEXT_METHODS, :to => Proxy

      @client = Client.new(@config.api_key, @config.endpoint)

      return true
    end

    def pot_path
      File.join(Translation.config.locales_path, "#{TEXT_DOMAIN}.pot")
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
