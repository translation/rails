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

              ruby_data.each_line do |line|
                entries += extract_line(line)
              end
            rescue Haml::SyntaxError
              TranslationIO.info "File cannot be parsed (SyntaxError): #{haml_file_path}", 1, 0
            end
          end

          TranslationIO.info "#{entries.size} entries found", 2, 2

          entries
        end

        def extract_line(line)
          entries = []

          sorted_gettext_methods = [
            :gettext, :sgettext, :ngettext, :nsgettext, :pgettext, :npgettext,
            :np_, :ns_, :Nn_, :n_, :p_, :s_, :N_, :_
          ]

          sorted_gettext_methods.each do |method|
            if index = line.index("#{method}(")
              pos = index + "#{method}(".length
              if line[pos] == '"' || ("#{method}"[0] == 'n' && line[pos] == '[')
                end_pos = line[index...-1].index(')')
                entries << line[index...index+end_pos+1]
                entries += extract_line(line[index+end_pos+1...-1] + "\n")
                break
              end
            end
          end

          return entries
        end
      end
    end
  end
end
