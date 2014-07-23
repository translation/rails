module Translation
  class Client
    class BaseOperation
      class DumpSlimGettextKeysStep

        GETTEXT_ENTRY_RE = /(?:n|p|s|np|ns|N|Nn|gettext|sgettext|ngettext|nsgettext|pgettext|npgettext)?_\([^)]+\)?\)/

        def initialize(slim_source_files)
          @slim_source_files = slim_source_files
        end

        def run
          if @slim_source_files.any? && defined?(Slim)
            Translation.info "Extracting Gettext entries from SLIM files."

            File.open(File.join('tmp', 'translation-slim-gettext.rb'), 'w') do |file|
              extracted_gettext_entries.each do |entry|
                file.puts "#{entry}"
              end
            end
          end
        end

        protected

        def extracted_gettext_entries
          entries = []

          @slim_source_files.each do |slim_file_path|
            Translation.info slim_file_path, 2, 2

            ruby_data = Slim::Template.new(slim_file_path, {}).precompiled_template

            ruby_data.scan(GETTEXT_ENTRY_RE).each do |entry|
              entries << entry
            end
          end

          Translation.info "#{entries.size} entries found", 2, 2

          entries
        end
      end
    end
  end
end
