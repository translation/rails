module TranslationIO
  class Client
    class SyncOperation < BaseOperation
      class ApplyYamlSourceEditsStep
        def initialize(yaml_file_paths, source_locale)
          @yaml_file_paths = yaml_file_paths
          @source_locale   = source_locale
        end

        def run(params)
          TranslationIO.info "Downloading YAML source editions."

          params.merge!({ :timestamp => metadata_timestamp })
          parsed_response = perform_source_edits_request(params)
          source_edits    = parsed_response['source_edits'].to_a

          TranslationIO.info "Applying YAML source editions."

          source_edits.each do |source_edit|
            inserted = false

            reload_or_reuse_yaml_sources

            @yaml_sources.each do |yaml_source|
              yaml_file_path = yaml_source[:yaml_file_path]
              yaml_flat_hash = yaml_source[:yaml_flat_hash]

              yaml_flat_hash.each do |full_key, value|
                if full_key == "#{@source_locale}.#{source_edit['key']}"
                  inserted = apply_source_edit(source_edit, yaml_file_path, yaml_flat_hash)
                  break if inserted
                end
              end

              break if inserted
            end
          end

          update_metadata_timestamp
        end

        private

        def reload_or_reuse_yaml_sources
          if yaml_sources_reload_needed?
            @yaml_sources = sort_by_project_locales_first(@yaml_file_paths).collect do |yaml_file_path|
              yaml_content   = File.read(yaml_file_path)
              yaml_hash      = YAML::load(yaml_content)
              yaml_flat_hash = FlatHash.to_flat_hash(yaml_hash)

              {
                :yaml_file_path => yaml_file_path,
                :yaml_flat_hash => yaml_flat_hash
              }
            end
          else
            @yaml_sources
          end
        end

        def yaml_sources_reload_needed?
          @yaml_file_paths.sort != @yaml_sources.to_a.collect { |y_s| y_s[:yaml_file_path] }.sort
        end

        # Sort YAML file paths by project locales first, gem locales after
        # (to replace "overridden" source first)
        def sort_by_project_locales_first(yaml_file_paths)
          yaml_file_paths.sort do |x, y|
            a = locale_file_path_in_project?(x)
            b = locale_file_path_in_project?(y)
            (!a && b) ? 1 : ((a && !b) ? -1 : 0)
          end
        end

        def apply_source_edit(source_edit, yaml_file_path, yaml_flat_hash)
          full_key = "#{@source_locale}.#{source_edit['key']}"

          if yaml_flat_hash[full_key] == source_edit['old_text']
            TranslationIO.info "#{source_edit['key']} | #{source_edit['old_text']} -> #{source_edit['new_text']}", 2, 2

            if locale_file_path_in_project?(yaml_file_path)
              apply_application_source_edit(source_edit, yaml_file_path, yaml_flat_hash)
            else # override source text of gem inside the app
              apply_gem_source_edit(source_edit)
            end

            return true
          else
            TranslationIO.info "#{source_edit['key']} | Ignored because translation was also updated in source YAML file", 2, 2
            return false
          end
        end

        def apply_application_source_edit(source_edit, yaml_file_path, yaml_flat_hash)
          full_key                 = "#{@source_locale}.#{source_edit['key']}"
          yaml_flat_hash[full_key] = source_edit['new_text']
          file_content             = to_hash_to_yaml(yaml_flat_hash)

          File.open(yaml_file_path, 'w') do |f|
            f.write(file_content)
          end
        end

        def apply_gem_source_edit(source_edit)
          yaml_file_path = File.join(TranslationIO.config.yaml_locales_path, "#{@source_locale}.yml")

          if File.exists?(yaml_file_path) # source yaml file
            existing_yaml_source = @yaml_sources.detect { |y_s| y_s[:yaml_file_path] == yaml_file_path }
            yaml_flat_hash       = existing_yaml_source[:yaml_flat_hash]
          else
            FileUtils::mkdir_p File.dirname(yaml_file_path)
            yaml_flat_hash = {}
            @yaml_file_paths = [yaml_file_path] + @yaml_file_paths
          end

          apply_application_source_edit(source_edit, yaml_file_path, yaml_flat_hash)
        end

        def to_hash_to_yaml(yaml_flat_hash)
          yaml_hash = FlatHash.to_hash(yaml_flat_hash)

          if TranslationIO.config.yaml_line_width
            content = yaml_hash.to_yaml(:line_width => TranslationIO.config.yaml_line_width)
          else
            content = yaml_hash.to_yaml
          end

          content.gsub(/ $/, '') # remove trailing spaces
        end

        def metadata_timestamp
          if File.exist?(TranslationIO.config.metadata_path)
            metadata_content = File.read(TranslationIO.config.metadata_path)

            if metadata_content.include?('>>>>') || metadata_content.include?('<<<<')
              TranslationIO.info "[Error] #{TranslationIO.config.metadata_path} file is corrupted and seems to have unresolved versioning conflicts. Please resolve them and try again."
              exit(false)
            else
              return YAML::load(metadata_content)['timestamp'] rescue 0
            end
          else
            return 0
          end
        end

        def update_metadata_timestamp
          File.open(TranslationIO.config.metadata_path, 'w') do |f|
            f.write({ 'timestamp' => Time.now.utc.to_i }.to_yaml)
          end
        end

        def perform_source_edits_request(params)
          uri             = URI("#{TranslationIO.client.endpoint}/projects/#{TranslationIO.client.api_key}/source_edits")
          parsed_response = BaseOperation.perform_request(uri, params)
        end

        def locale_file_path_in_project?(locale_file_path)
          TranslationIO.normalize_path(locale_file_path).start_with?(
            TranslationIO.normalize_path(TranslationIO.config.yaml_locales_path)
          )
        end
      end
    end
  end
end
