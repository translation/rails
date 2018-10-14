require 'gettext'
require 'gettext/po'
require 'gettext/po_parser'
require 'gettext/tools'

namespace :translation do

  desc "Get configuration infos of Translation gem."
  task :config => :environment do
    puts TranslationIO.config
  end

  desc "Initialize Translation.io with existing keys/strings."
  task :init => :environment do
    if client_ready?
      TranslationIO.client.init
    end
  end

  desc "Send new translatable keys/strings and get new translations from Translation.io"
  task :sync => :environment do
    if client_ready?
      TranslationIO.client.sync
    end
  end

  desc "Sync translations and find out the unused keys/string from Translation.io, using the current branch as reference."
  task :sync_and_show_purgeable => :environment do
    if client_ready?
      TranslationIO.client.sync_and_show_purgeable
    end
  end

  desc "Sync translations and remove unused keys from Translation.io, using the current branch as reference."
  task :sync_and_purge => :environment do
    if client_ready?
      TranslationIO.client.sync_and_purge
    end
  end

  desc "Sync translations but only get translated segments without changing anything on Translation.io (it allows concurrent syncing for CI)."
  task :sync_readonly => :environment do
    if client_ready?
      TranslationIO.client.sync_readonly
    end
  end

  def client_ready?
    if TranslationIO.client
      true
    else
      TranslationIO.info("[Error] Can't configure client. Did you set up the initializer?\n"\
                         "Read usage instructions here : http://translation.io/usage")
      false
    end
  end
end
