module TranslationIO
  class Client
    class InitOperation < BaseOperation
      class CleanupYamlFilesStep
        def initialize(source_locale, target_locales, yaml_file_paths, yaml_locales_path)
          @source_locale     = source_locale
          @target_locales    = target_locales
          @yaml_file_paths   = yaml_file_paths
          @yaml_locales_path = yaml_locales_path
        end

        def run
          @yaml_file_paths.each do |locale_file_path|
            if locale_file_removable?(locale_file_path)
              content_hash        = TranslationIO.yaml_load(File.read(locale_file_path)) || {}
              source_content_hash = content_hash.reject { |k| k.to_s.in?(@target_locales.collect(&:to_s)) }

              if source_content_hash.empty?
                TranslationIO.info "Removing #{locale_file_path}", 2, 2
                FileUtils.rm(locale_file_path)
              elsif content_hash != source_content_hash # in case of mixed languages in source YAML file
                TranslationIO.info "Rewriting #{locale_file_path}", 2, 2

                if TranslationIO.config.yaml_line_width
                  file_content = source_content_hash.to_yaml(:line_width => TranslationIO.config.yaml_line_width)
                else
                  file_content = source_content_hash.to_yaml
                end

                file_content = file_content.gsub(/ $/, '') # remove trailing spaces

                File.open(locale_file_path, 'wb') do |file|
                  file.write(file_content)
                end
              else
                # don't touch source
              end
            end
          end
        end

        private

        def locale_file_removable?(locale_file_path)
          exists     = File.exist?(locale_file_path)
          in_project = locale_file_path_in_project?(locale_file_path)

          protected_file = @target_locales.any? do |target_locale|
            paths = [
              TranslationIO.normalize_path(File.join(@yaml_locales_path, "translation.#{target_locale}.yml" ).to_s),
              TranslationIO.normalize_path(File.join(@yaml_locales_path, "localization.#{target_locale}.yml").to_s)
            ]

            paths.include?(TranslationIO.normalize_path(locale_file_path))
          end

          exists && in_project && !protected_file
        end

        def locale_file_path_in_project?(locale_file_path)
          TranslationIO.normalize_path(locale_file_path).start_with?(
            TranslationIO.normalize_path(@yaml_locales_path)
          )
        end
      end
    end
  end
end
