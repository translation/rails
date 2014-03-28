require 'gettext/tools'

namespace :translation do
  task :config => :environment do
    puts Translation.config
  end

  task :find do

  end

  task :make_mo => :environment do
    Dir["#{Translation.config.locales_path}/*"].each do |dir|
      if File.directory?(dir) && Translation.config.target_locales.map(&:to_s).include?(File.basename(dir))
        po_path = "#{dir}/app.po"
        mo_path = "#{dir}/LC_MESSAGES/app.mo"

        FileUtils.mkdir_p("#{dir}/LC_MESSAGES")
        GetText::Tools::MsgFmt.run(po_path, '-o', mo_path)
      end
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

