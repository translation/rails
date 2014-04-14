module Translation
  class WebserviceClient
    attr_reader :api_key, :endpoint

    def initialize(api_key, endpoint)
      @api_key  = api_key
      @endpoint = endpoint
    end

    def push
      uri    = URI("http://#{endpoint}/projects/#{api_key}/push")
      params = {}

      Translation.locale_paths.each do |locale_path|
        po_path     = "#{locale_path}/app.po"
        locale_code = File.basename(locale_path).downcase

        params["po_data_#{locale_code}"] = File.read(po_path)
      end

      response = Net::HTTP.post_form(uri, params)

      if response.code.to_i == 200
        Translation.info "Pushed."
      else
        Translation.info "Error."
      end
    end

    def init

    end

    def sync

    end

    def purge

    end
  end
end
