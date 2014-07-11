require 'gettext/tools'

namespace :translation do
  task :config => :environment do
    puts Translation.config
  end

  task :init => :environment do
    if Translation.client
      Translation.client.init
    else
      Translation.info "[Error] Client cannot be built. Did you set up the initializer?"
    end
  end

  task :sync => :environment do
    if Translation.client
     Translation.client.sync
   else
    Translation.info "[Error] Client cannot be built. Did you set up the initializer?"
   end
  end

  task :purge => :environment do
    if Translation.client
      Translation.client.purge
    else
      Translation.info "[Error] Client cannot be built. Did you set up the initializer?"
    end
  end
end
