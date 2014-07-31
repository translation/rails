require 'gettext/tools'

namespace :translation do
  task :config => :environment do
    puts TranslationIO.config
  end

  task :init => :environment do
    if TranslationIO.client
      TranslationIO.client.init
    else
      TranslationIO.info "[Error] Client cannot be built. Did you set up the initializer?"
    end
  end

  task :sync => :environment do
    if TranslationIO.client
     TranslationIO.client.sync
   else
    TranslationIO.info "[Error] Client cannot be built. Did you set up the initializer?"
   end
  end

  task :purge => :environment do
    if TranslationIO.client
      TranslationIO.client.purge
    else
      TranslationIO.info "[Error] Client cannot be built. Did you set up the initializer?"
    end
  end
end
