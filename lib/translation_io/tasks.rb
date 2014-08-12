require 'gettext/tools'

namespace :translation do
  task :config => :environment do
    puts TranslationIO.config
  end

  [ :init, :sync, :purge ].each do |t|
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
end
