require 'gettext'
require 'gettext/po'
require 'gettext/po_parser'
require 'gettext/tools'
require 'translation_io/client'
require 'optparse'

namespace :translation do

  desc "Get configuration infos of Translation gem."
  task :config => :environment do
    puts TranslationIO.config
  end

  desc "Initialize Translation.io with existing keys/strings."
  task :init => :environment do
    config = TranslationIO.config
    if config.domains.present?
      parse_domains.each do |domain|
        config.set_domain(fetch_domain(domain))
        TranslationIO.client = TranslationIO::Client.new(config.api_key, config.endpoint)
        TranslationIO.client.init
      end
    elsif client_ready?
      TranslationIO.client.init
    end
  end

  desc "Send new translatable keys/strings and get new translations from Translation.io"
  task :sync => :environment do
    config = TranslationIO.config
    if config.domains.present?
      parse_domains.each do |domain|
        config.set_domain(fetch_domain(domain))
        TranslationIO.client = TranslationIO::Client.new(config.api_key, config.endpoint)
        TranslationIO.client.sync
      end
    elsif client_ready?
      TranslationIO.client.sync
    end
  end

  desc "Sync translations and find out the unused keys/string from Translation.io, using the current branch as reference."
  task :sync_and_show_purgeable => :environment do
    config = TranslationIO.config
    if config.domains.present?
      parse_domains.each do |domain|
        config.set_domain(fetch_domain(domain))
        TranslationIO.client = TranslationIO::Client.new(config.api_key, config.endpoint)
        TranslationIO.client.sync_and_show_purgeable
      end
    elsif client_ready?
      TranslationIO.client.sync_and_show_purgeable
    end
  end

  desc "Sync translations and remove unused keys from Translation.io, using the current branch as reference."
  task :sync_and_purge => :environment do
    config = TranslationIO.config
    if config.domains.present?
      parse_domains.each do |domain|
        config.set_domain(fetch_domain(domain))
        TranslationIO.client = TranslationIO::Client.new(config.api_key, config.endpoint)
        TranslationIO.client.sync_and_purge
      end
    elsif client_ready?
      TranslationIO.client.sync_and_purge
    end
  end

  desc "Sync translations but only get translated segments without changing anything on Translation.io (it allows concurrent syncing for CI)."
  task :sync_readonly => :environment do
    config = TranslationIO.config
    if config.domains.present?
      parse_domains.each do |domain|
        config.set_domain(fetch_domain(domain))
        TranslationIO.client = TranslationIO::Client.new(config.api_key, config.endpoint)
        TranslationIO.client.sync_readonly
      end
    elsif client_ready?
      TranslationIO.client.sync_readonly
    end
  end

  private

  def client_ready?
    if TranslationIO.client
      true
    else
      TranslationIO.info("[Error] Can't configure client. Did you set up the initializer?\n"\
                         "Read usage instructions here : http://translation.io/usage")
      false
    end
  end

  def parse_domains
    domains = nil

     o = OptionParser.new do |opts|
      opts.banner = "Usage: rake add [options]"
      opts.on("-d", "--domains ARG", String) { |domain| domains = domain.split{','} }
    end
    args = o.order!(ARGV) {}
    o.parse!(args)
    if domains.nil?
      # default to all domains if none passed in
      TranslationIO.config.domains.collect{|d| d[:name]}
    else
      domains
    end
  end

  def fetch_domain(domain_name)
    TranslationIO.config.domains.select{|d| d[:name]==domain_name}.first
  end
end
