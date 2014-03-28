require 'gettext/tools'

namespace :translation do
  task :config => :environment do
    puts Translation.config
  end

  task :update_pot => :environment do
    pot_path     = "#{Translation.config.locales_path}/app.pot"
    source_files = Dir['**/*.{rb,erb}']

    GetText::Tools::XGetText.run(*source_files, '-o', pot_path)
  end

  task :update_pos => :environment do
    pot_path = "#{Translation.config.locales_path}/app.pot"

    Translation.locale_paths.each do |locale_path|
      po_path = "#{locale_path}/app.po"
      GetText::Tools::MsgMerge.run(po_path, pot_path, '-o', po_path)
    end
  end

  task :make_mos => :environment do
    Translation.locale_paths.each do |locale_path|
      po_path = "#{locale_path}/app.po"
      mo_path = "#{locale_path}/LC_MESSAGES/app.mo"

      FileUtils.mkdir_p("#{locale_path}/LC_MESSAGES")
      GetText::Tools::MsgFmt.run(po_path, '-o', mo_path)
    end
  end
end











# module TranslationIO
#   module YamlToGettext
#     def self.get_pot_data
#       source_locale = :en

#       if I18n.available_locales.include?(source_locale)
#         pot_data = ""

#         I18n.load_path.each do |load_path|
#           content = YAML::load(File.read(load_path))

#           if content[source_locale.to_s]
#             build_pot_level(pot_data, nil, content[source_locale.to_s])
#           end
#         end

#         return pot_data
#       else
#         raise "Source locale must be in available locales"
#       end
#     end

#     def self.build_pot_level(pot_data, parent_key, locales_hash)
#       locales_hash.each_pair do |key, value|
#         current_level_key = [parent_key, key].reject(&:blank?).join('.')

#         if value.is_a?(Hash)
#           build_pot_level(pot_data, current_level_key, value)
#         else
#           pot_data << "# #{current_level_key}\n"
#           pot_data << "msgid \"#{value}\"\n" # TODO : escape ""
#           pot_data << "msgstr \"\"\n\n" # TODO : escape ""
#         end
#       end
#     end
#   end
# end

# namespace :translation do
#   namespace :io do
#     task :convert => :environment do
#       puts TranslationIO::YamlToGettext.get_pot_data
#     end
#   end
# end

