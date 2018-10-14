require 'translation_io/client/base_operation'
require 'translation_io/client/init_operation'
require 'translation_io/client/sync_operation'

module TranslationIO
  class Client
    attr_reader :api_key, :endpoint

    def initialize(api_key, endpoint)
      @api_key  = api_key
      @endpoint = endpoint
    end

    def init
      TranslationIO::Client::InitOperation.new(self).run
    end

    def sync
      TranslationIO::Client::SyncOperation.new(self).run
    end

    def sync_and_show_purgeable
      TranslationIO::Client::SyncOperation.new(self).run(:show_purgeable => true)
    end

    def sync_and_purge
      TranslationIO::Client::SyncOperation.new(self).run(:purge => true)
    end

    def sync_readonly
      TranslationIO::Client::SyncOperation.new(self).run(:readonly => true)
    end
  end
end
