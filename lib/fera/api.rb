require 'require_all'

require 'active_resource'

require_rel "./api/version"
require_rel "./api"
require_rel "./app"
require_rel "./models"
require_rel "./models/concerns"

module Fera
  module API
    class Error < StandardError; end

    DEFAULT_HEADERS = {
      'Api-Client' => "fera_ruby_sdk-#{ API::VERSION }",
    }

    ##
    # @param api_key [String] Public API key, Secret API key or Auth Token (if app)
    # @return [Object, ::Fera::API] Result of the block operation if given, otherwise self
    def self.configure(api_key, api_url: nil, strict_mode: false, debug_mode: false, api_type: nil)
      previous_base_site = Base.site.dup
      previous_base_headers = Base.headers.dup
      previous_debug_mode = @debug_mode

      api_url ||= 'https://api.fera.ai'
      api_type ||= api_key.include?('sk_') ? 'private' : 'public'
      Base.site = "#{ api_url.chomp('/') }/v3/#{ api_type }"

      @debug_mode = debug_mode

      Base.api_key = api_key
      Base.headers['Strict-Mode'] = strict_mode if strict_mode

      if block_given?
        begin
          result = yield
        ensure
          Base.site = previous_base_site
          Base.headers = previous_base_headers
          @debug_mode = previous_debug_mode
        end

        result
      else
        self
      end
    end

    def self.debug_mode?; @debug_mode; end

    ##
    # @option client_id [String] Fera app Client ID
    # @option client_secret [String] Fera app Client secret
    # @option auth_token [String] Auth token you wish to revoke access for.
    def self.revoke_token!(client_id:, client_secret:, auth_token:)
      previous_site = Base.site

      Base.site = "https://app.fera.ai"

      body = { client_id: client_id, client_secret: client_secret, token: auth_token }

      result = Base.connection.post("https://app.fera.ai/oauth/revoke", body.to_json)

      Base.site = previous_site

      result
    end
  end
end
Fera::Api = Fera::API # @alias
