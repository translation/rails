require 'gettext/tools'

namespace :translation do
  task :config => :environment do
    puts Translation.config
  end

  # task :update_pot => :environment do
  #   pot_path     = "#{Translation.config.locales_path}/app.pot"
  #   source_files = Dir['**/*.{rb,erb}']

  #   GetText::Tools::XGetText.run(*source_files, '-o', pot_path)
  # end

  # task :update_pos => :environment do
  #   Translation.locale_paths.each do |locale_path|
  #     po_path = "#{locale_path}/app.po"
  #     GetText::Tools::MsgMerge.run(po_path, Translation.pot_path, '-o', po_path)
  #   end
  # end

  # task :make_mos => :environment do
  #   Translation.locale_paths.each do |locale_path|
  #     po_path = "#{locale_path}/app.po"
  #     mo_path = "#{locale_path}/LC_MESSAGES/app.mo"

  #     FileUtils.mkdir_p("#{locale_path}/LC_MESSAGES")
  #     GetText::Tools::MsgFmt.run(po_path, '-o', mo_path)
  #   end
  # end

  task :sync => :environment do
    Translation.client.sync
  end

  task :debug => :environment do
    Translation::YAMLConversion.get_pot_data_from_yaml
  end
end
