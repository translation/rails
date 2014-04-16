module Translation
  class Client
    class Sync
      attr_accessor :client

      def initialize(client)
        @client = client
      end

      def run
        # Update local POT
        Translation.info "Updating POT."
        pot_path     = "#{Translation.config.locales_path}/app.pot"
        source_files = Dir['**/*.{rb,erb}']
        GetText::Tools::XGetText.run(*source_files, '-o', pot_path)

        # Generate YAML POT
        Translation.info "Extracting YAML translations to POT file."
        yaml_pot_data = YAMLConversion.get_pot_data_from_yaml

        # Send
        Translation.info "Pushing POT files."
        uri = URI("http://#{client.endpoint}/projects/#{client.api_key}/sync")

        begin
          response = Net::HTTP.post_form(uri, {
            'gem_version'        => Translation.version,
            'pot_data'           => File.read(Translation.pot_path),
            'yaml_pot_data'      => yaml_pot_data,
            'target_languages[]' => Translation.config.target_locales.map(&:to_s)
          })

          parsed_response = JSON.parse(response.body)

          if response.code.to_i == 200
            if parsed_response.has_key?('po_data')
              Translation.config.target_locales.each do |target_locale|
                if parsed_response['po_data'].has_key?(target_locale.to_s)
                  Translation.info "Saving PO file translations for #{target_locale}."
                  FileUtils.mkdir_p("#{Translation.config.locales_path}/#{target_locale}")
                  po_path = "#{Translation.config.locales_path}/#{target_locale}/app.po"

                  File.open(po_path, 'w') do |file|
                    file.write(parsed_response['po_data'][target_locale.to_s])
                  end

                  Translation.info "Generating MO file.", 1
                  FileUtils.mkdir_p("#{Translation.config.locales_path}/#{target_locale}/LC_MESSAGES")
                  mo_path = "#{Translation.config.locales_path}/#{target_locale}/LC_MESSAGES/app.mo"
                  GetText::Tools::MsgFmt.run(po_path, '-o', mo_path)
                end
              end
            end

            if parsed_response.has_key?('yaml_po_data')
              Translation.config.target_locales.each do |target_locale|
                if parsed_response['yaml_po_data'].has_key?(target_locale.to_s)
                  Translation.info "Generating YAML file for #{target_locale}."
                  YAMLConversion.write_yaml_data_from_po(target_locale, parsed_response['yaml_po_data'][target_locale.to_s])
                end
              end
            end
          else
            if response.code.to_i == 400 && parsed_response.has_key?('error')
              $stderr.puts "[Error] #{parsed_response['error']}"
            else
              $stderr.puts "[Error] Unknown error."
            end
          end
        rescue Errno::ECONNREFUSED
          $stderr.puts "[Error] Server not responding."
        end
      end

    end
  end
end
