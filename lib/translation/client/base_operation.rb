module Translation
  class Client
    class BaseOperation
      attr_accessor :client, :params

      def initialize(client)
        @client = client
        @params = {
          'gem_version'        => Translation.version,
          'target_languages[]' => Translation.config.target_locales.map(&:to_s)
        }
      end

      private

      def perform_request(uri, params)
        begin
          response        = Net::HTTP.post_form(uri, params)
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
