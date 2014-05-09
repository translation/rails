module Translation
  class Client
    class BaseOperation
      attr_accessor :client, :params

      def initialize(client, perform_real_requests = true)
        @client = client
        @params = {
          'gem_version'        => Translation.version,
          'target_languages[]' => Translation.config.target_locales.map(&:to_s)
        }
      end

      private

      def perform_request(uri, params)
        begin
          http = Net::HTTP.new(uri.host, uri.port)
          http.read_timeout = 500

          request = Net::HTTP::Post.new(uri.request_uri)
          request.set_form_data(params)

          response        = http.request(request)
          parsed_response = JSON.parse(response.body)

          if response.code.to_i == 200
            return parsed_response
          elsif response.code.to_i == 400 && parsed_response.has_key?('error')
            $stderr.puts "[Error] #{parsed_response['error']}"
          else
            $stderr.puts "[Error] Unknown error."
          end
        rescue Errno::ECONNREFUSED
          $stderr.puts "[Error] Server not responding."
        end
      end
    end
  end
end
