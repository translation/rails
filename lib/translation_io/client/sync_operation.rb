require 'translation_io/client/sync_operation/create_yaml_pot_file_step'
require 'translation_io/client/sync_operation/apply_yaml_source_edits_step'

module TranslationIO
  class Client
    class SyncOperation < BaseOperation
      def run(options = {})
        purge          = options.fetch(:purge,          false)
        show_purgeable = options.fetch(:show_purgeable, false)
        readonly       = options.fetch(:readonly,       false)

        config = TranslationIO.config

        source_files      = config.source_files
        erb_source_files  = config.erb_source_files
        haml_source_files = config.haml_source_files
        slim_source_files = config.slim_source_files
        pot_path          = config.pot_path
        source_locale     = config.source_locale
        target_locales    = config.target_locales
        locales_path      = config.locales_path
        yaml_locales_path = config.yaml_locales_path
        yaml_file_paths   = config.yaml_file_paths

        ApplyYamlSourceEditsStep.new(yaml_file_paths, source_locale).run(params)

        unless config.disable_gettext
          BaseOperation::DumpMarkupGettextKeysStep.new(haml_source_files, :haml).run
          BaseOperation::DumpMarkupGettextKeysStep.new(slim_source_files, :slim).run
        end

        UpdatePotFileStep.new(pot_path, source_files + erb_source_files).run(params)
        CreateYamlPotFileStep.new(source_locale, yaml_file_paths).run(params)

        if purge
          params['purge'] = 'true'
        end

        if readonly
          params['readonly'] = 'true'
        end

        TranslationIO.info "Sending data to server (it may take some time, please be patient)."

        uri             = URI("#{client.endpoint}/projects/#{client.api_key}/sync")
        parsed_response = BaseOperation.perform_request(uri, params)

        unless parsed_response.nil?
          BaseOperation::SaveNewPoFilesStep.new(target_locales, locales_path, parsed_response).run
          BaseOperation::CreateNewMoFilesStep.new(locales_path).run
          BaseOperation::SaveNewYamlFilesStep.new(target_locales, yaml_locales_path, parsed_response).run
          BaseOperation::SaveSpecialYamlFilesStep.new(source_locale, target_locales, yaml_locales_path, yaml_file_paths).run

          display_unused_segments(parsed_response, show_purgeable, purge)

          info_project_url(parsed_response)
        end

        cleanup
      end

      def display_unused_segments(parsed_response, show_purgeable, purge)
        unused_segments         = parsed_response['unused_segments'] || []
        yaml_unused_segments    = unused_segments.select { |unused_segment| unused_segment['kind'] == 'yaml' }
        gettext_unused_segments = unused_segments.select { |unused_segment| unused_segment['kind'] == 'gettext' }

        yaml_size    = yaml_unused_segments.size
        gettext_size = gettext_unused_segments.size
        total_size   = yaml_size + gettext_size

        # Quick unused segments summary for simple "sync"
        if !show_purgeable && !purge
          if total_size > 0
            puts
            puts "----------"
            puts "#{yaml_size + gettext_size} keys/strings are in Translation.io but not in your current branch."
            puts 'Execute "rake translation:sync_and_show_purgeable" to list these keys/strings.'
          end
        # Complete summary for sync_and_show_purgeable or sync_and_purge
        else
          if purge
            text = "were removed from Translation.io to match your current branch:"
          elsif show_purgeable
            text = "are in Translation.io but not in your current branch:"
          end

          if yaml_size > 0
            puts
            puts "----------"
            puts "#{yaml_size} YAML #{yaml_size == 1 ? 'key' : 'keys'} #{text}"
            puts

            yaml_unused_segments.each do |yaml_unused_segment|
              puts "[#{yaml_unused_segment['languages']}] [#{yaml_unused_segment['msgctxt']}] \"#{yaml_unused_segment['msgid']}\""
            end
          end

          if gettext_size > 0
            puts
            puts "----------"
            puts "#{gettext_size} GetText #{gettext_size == 1 ? 'string' : 'strings'} #{text}"
            puts

            gettext_unused_segments.each do |gettext_unused_segment|
              puts "[#{gettext_unused_segment['languages']}] \"#{gettext_unused_segment['msgid']}\""
            end
          end

          # Special message for when nothing need to be purged
          if total_size == 0
            puts
            puts "----------"
            puts "Nothing to purge: all the keys/strings in Translation.io are also in your current branch."
          end

          # Special message when sync_and_show_purgeable and unused segments
          if show_purgeable && total_size > 0
            puts
            puts "----------"
            puts "If you know what you are doing, you can remove them using \"rake translation:sync_and_purge\"."
          end
        end
      end

      def info_project_url(parsed_response)
        puts
        puts "----------"
        puts "Use this URL to translate: #{parsed_response['project_url']}"
        puts "----------"
      end
    end
  end
end
