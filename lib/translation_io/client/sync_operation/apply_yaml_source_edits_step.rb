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

          unless parsed_response.nil?
            TranslationIO.info "Applying YAML source editions."

            parsed_response['source_edits'].each do |source_edit|
              inserted = false

              sort_by_project_locales_first(@yaml_file_paths).each do |file_path|
                yaml_hash      = YAML::load(File.read(file_path))
                flat_yaml_hash = FlatHash.to_flat_hash(yaml_hash)

                flat_yaml_hash.each do |key, value|
                  if key == "#{@source_locale}.#{source_edit['key']}"
                    if value == source_edit['old_text']
                      TranslationIO.info "#{source_edit['key']} | #{source_edit['old_text']} -> #{source_edit['new_text']}", 2, 2

                      if locale_file_path_in_project?(file_path)
                        flat_yaml_hash[key] = source_edit['new_text']

                        File.open(file_path, 'w') do |f|
                          f.write(FlatHash.to_hash(flat_yaml_hash).to_yaml)
                        end
                      else # override source text of gem
                        yaml_path = File.join(TranslationIO.config.yaml_locales_path, "#{@source_locale}.yml")

                        if File.exists?(yaml_path) # source yaml file
                          yaml_hash      = YAML::load(File.read(yaml_path))
                          flat_yaml_hash = FlatHash.to_flat_hash(yaml_hash)
                        else
                          FileUtils::mkdir_p File.dirname(yaml_path)
                          flat_yaml_hash = {}
                        end

                        flat_yaml_hash["#{@source_locale}.#{source_edit['key']}"] = source_edit['new_text']

                        File.open(yaml_path, 'w') do |f|
                          f.write(FlatHash.to_hash(flat_yaml_hash).to_yaml)
                        end
                      end

                      inserted = true
                      break
                    else
                      TranslationIO.info "#{source_edit['key']} | Ignored because translation was also updated in source YAML file", 2, 2
                    end
                  end
                end

                break if inserted
              end
            end
          end

          File.open(TranslationIO.config.metadata_path, 'w') do |f|
            f.write({ 'timestamp' => Time.now.utc.to_i }.to_yaml)
          end
        end

        private

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

        def perform_source_edits_request(params)
          uri             = URI("#{TranslationIO.client.endpoint}/projects/#{TranslationIO.client.api_key}/source_edits")
          parsed_response = BaseOperation.perform_request(uri, params)
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

        def locale_file_path_in_project?(locale_file_path)
          TranslationIO.normalize_path(locale_file_path).start_with?(
            TranslationIO.normalize_path(TranslationIO.config.yaml_locales_path)
          )
        end
      end
    end
  end
end
