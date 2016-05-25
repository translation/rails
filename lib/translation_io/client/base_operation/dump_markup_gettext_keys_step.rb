module TranslationIO
  class Client
    class BaseOperation
      class DumpMarkupGettextKeysStep
        def initialize(markup_source_files, markup_type)
          @markup_source_files = markup_source_files
          @markup_type         = markup_type
        end

        def run
          if @markup_source_files.any?
            TranslationIO.info "Extracting Gettext entries from #{@markup_type.to_s.upcase} files."

            FileUtils.mkdir_p(File.join('tmp', 'translation'))

            extracted_gettext_entries.each_with_index do |entry, index|
              file_path = File.join('tmp', 'translation', "#{@markup_type}-gettext-#{index.to_s.rjust(8,'0')}.rb")

              File.open(file_path, 'w') do |file|
                file.puts "def fake"
                file.puts "  #{entry}"
                file.puts "end"
              end
            end
          end
        end

        protected

        def extracted_gettext_entries
          entries = []

          @markup_source_files.each do |markup_file_path|
            TranslationIO.info markup_file_path, 2, 2

            markup_data = File.read(markup_file_path)
            entries    += TranslationIO::Extractor.extract(markup_data)
          end

          TranslationIO.info "#{entries.size} entries found", 2, 2

          entries
        end
      end
    end
  end
end
