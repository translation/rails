require 'translation/client/base_operation'
require 'translation/client/init_operation'
require 'translation/client/sync_operation'
require 'translation/client/purge_operation'

module Translation
  class Client
    attr_reader :api_key, :endpoint

    def initialize(api_key, endpoint)
      @api_key  = api_key
      @endpoint = endpoint
    end

    def init
      Translation::Client::InitOperation.new(self).run
    end

    def sync
      Translation::Client::SyncOperation.new(self).run
    end

    def purge
      Translation::Client::PurgeOperation.new(self).run
    end
  end
end
