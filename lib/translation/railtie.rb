module Translation
  class Railtie < Rails::Railtie
    rake_tasks do
      require 'translation/tasks'
    end
  end
end
