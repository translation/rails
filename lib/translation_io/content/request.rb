module TranslationIO
  module Content
    class Request
      def initialize(uri, params = {})
        @uri    = uri
        @params = params

        @params.merge!({
          'gem_version'        => TranslationIO.version,
          'source_language'    => TranslationIO::Content.config.source_locale.to_s,
          'target_languages[]' => TranslationIO::Content.config.target_locales.map(&:to_s)
        })
      end

      def perform
        begin
          http = Net::HTTP.new(@uri.host, @uri.port)
          http.use_ssl = @uri.scheme == 'https'
          http.read_timeout = 500

          request = Net::HTTP::Post.new(@uri.request_uri)
          request.set_form_data(@params)

          response        = http.request(request)
          parsed_response = JSON.parse(response.body)

          if response.code.to_i == 200
            return parsed_response
          elsif response.code.to_i == 400 && parsed_response.has_key?('error')
            $stderr.puts "[Error] #{parsed_response['error']}"
            exit
          else
            $stderr.puts "[Error] Unknown error from the server: #{response.code}."
            exit
          end
        rescue Errno::ECONNREFUSED
          $stderr.puts "[Error] Server not responding."
          exit
        end
      end
    end
  end
end
