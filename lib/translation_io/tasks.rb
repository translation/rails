require 'gettext'
require 'gettext/po'
require 'gettext/po_parser'
require 'gettext/tools'

namespace :translation do

  DESCRIPTIONS = {
    :init           => "Initialize your Translation.io project",
    :sync           => "Send new translatable keys/strings and get new translations from Translation.io",
    :sync_and_purge => "Remove unused keys/strings from Translation.io using the current branch as reference"
  }

  desc "Get configuration infos of Translation gem"
  task :config => :environment do
    puts TranslationIO.config
  end

  DESCRIPTIONS.each_pair do |t, description|
    desc description
    task t => :environment do
      if TranslationIO.client
        TranslationIO.client.send(t)
      else
        message = <<EOS
[Error] Can't configure client. Did you set up the initializer?
Read usage instructions here : http://translation.io/usage
EOS
        TranslationIO.info(message)
      end
    end
  end

  task :purge => :environment do
    TranslationIO.info("Purge is deprecated, please use rake 'translation:sync_and_purge' instead.")
  end
end
