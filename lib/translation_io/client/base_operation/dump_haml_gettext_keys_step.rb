module TranslationIO
  class Client
    class BaseOperation
      class DumpHamlGettextKeysStep
        def initialize(haml_source_files)
          @haml_source_files = haml_source_files
        end

        def run
          if @haml_source_files.any? && defined?(Haml)
            TranslationIO.info "Extracting Gettext entries from HAML files."

            File.open(File.join('tmp', 'translation-haml-gettext.rb'), 'w') do |file|
              extracted_gettext_entries.each do |entry|
                file.puts "#{entry}"
              end
            end
          end
        end

        protected

        def extracted_gettext_entries
          entries = []

          @haml_source_files.each do |haml_file_path|
            TranslationIO.info haml_file_path, 2, 2

            haml_data = File.read(haml_file_path)

            begin
              ruby_data = Haml::Engine.new(haml_data).precompiled

              ruby_data.scan(GETTEXT_ENTRY_RE).each do |entry|
                entries << entry
              end
            rescue Haml::SyntaxError
              TranslationIO.info "File cannot be parsed (SyntaxError): #{haml_file_path}", 1, 0
            end
          end

          TranslationIO.info "#{entries.size} entries found", 2, 2

          entries
        end
      end
    end
  end
end
