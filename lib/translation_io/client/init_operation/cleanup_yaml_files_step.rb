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
            in_project = locale_file_path_in_project?(locale_file_path)

            protected_file = @target_locales.any? do |target_locale|
              paths = [
                File.join(@yaml_locales_path, "translation.#{target_locale}.yml").to_s,
                File.join(@yaml_locales_path, "localization.#{target_locale}.yml").to_s
              ]

              paths.include?(locale_file_path)
            end

            if in_project && !protected_file
              content_hash     = YAML::load(File.read(locale_file_path))
              new_content_hash = content_hash.keep_if { |k| k.to_s == @source_locale.to_s }

              if new_content_hash.keys.any?
                TranslationIO.info "Rewriting #{locale_file_path}", 2, 2
                File.open(locale_file_path, 'wb') do |file|
                  file.write(new_content_hash.to_yaml)
                end
              else
                TranslationIO.info "Removing #{locale_file_path}", 2, 2
                FileUtils.rm(locale_file_path)
              end
            end
          end
        end

        private

        def locale_file_path_in_project?(locale_file_path)
          TranslationIO.normalize_path(locale_file_path).start_with?(
            TranslationIO.normalize_path(@yaml_locales_path)
          )
        end
      end
    end
  end
end
