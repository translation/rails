require 'translation/client/init'
require 'translation/client/sync'
require 'translation/client/purge'

module Translation
  class Client
    attr_reader :api_key, :endpoint

    def initialize(api_key, endpoint)
      @api_key  = api_key
      @endpoint = endpoint
    end

    def init
      Translation::Client::Init.new(self).run
    end

    def sync
      Translation::Client::Sync.new(self).run
    end

    def purge
      Translation::Client::Purge.new(self).run
    end
  end
end
