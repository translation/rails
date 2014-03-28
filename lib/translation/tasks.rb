namespace :translation do
  task :config => :environment do
    puts Translation.config
  end
end
