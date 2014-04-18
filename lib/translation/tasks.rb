require 'gettext/tools'

namespace :translation do
  task :config => :environment do
    puts Translation.config
  end

  task :init => :environment do
    Translation.client.init
  end

  task :sync => :environment do
    Translation.client.sync
  end

  task :debug => :environment do
    Translation::YAMLConversion.get_pot_data_from_yaml
  end
end
