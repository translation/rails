module Translation
  class Client
    class BaseOperation
      class DumpHamlGettextKeysStep

        GETTEXT_ENTRY_RE = /((?:n|p|s|np)?_)\(\s*"([^"]+)"\s*(?:,\s*"([^"]+)"\s*)?\)/

        def initialize(haml_source_files)
          @haml_source_files = haml_source_files
        end

        def run
          Translation.info "Extracting Gettext entries from HAML files."

          extracted_gettext_entries = []

          @haml_source_files.each do |haml_file_path|
            Translation.info haml_file_path, 2, 2

            haml_data = File.read(haml_file_path)
            ruby_data = Haml::Engine.new(haml_data).precompiled

            ruby_data.scan(GETTEXT_ENTRY_RE).each do |entry|
              extracted_gettext_entries << entry
            end
          end

          Translation.info "#{extracted_gettext_entries.size} entries found", 2, 2

          File.open(File.join('tmp', 'translation-haml-gettext.rb'), 'w') do |file|
            extracted_gettext_entries.each do |entry|
              method      = entry[0]
              params_list = [entry[1], entry[2]].compact.map { |p| "\"#{p}\"" }.join(', ')

              file.puts "#{method}(#{params_list})"
            end
          end
        end
      end
    end
  end
end
