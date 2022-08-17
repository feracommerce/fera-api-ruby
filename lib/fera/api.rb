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
    def self.configure(api_key, api_url: nil, strict_mode: false)
      previous_base_site = Base.site
      previous_base_headers = Base.headers

      api_url ||= 'https://api.fera.ai'
      Base.site = "#{ api_url.chomp('/') }/v3/private"

      if api_key =~ /^sk_/
        Base.headers['Secret-Key'] = api_key
      elsif api_key =~ /^pk_/
        Base.headers['Public-Key'] = api_key
      else
        Base.headers['Authorization'] = "Bearer #{ api_key }"
      end

      Base.headers['Strict-Mode'] = strict_mode if strict_mode

      if block_given?
        begin
          result = yield
        ensure
          Base.site = previous_base_site
          previous_base_headers.each do |key, value|
            Base.headers[key] = value
          end
        end

        result
      else
        self
      end
    end

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
