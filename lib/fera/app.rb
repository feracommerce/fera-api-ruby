module Fera
  class App
    def initialize(client_id, client_secret, options = {})
      @client_id = client_id
      @client_secret = client_secret
      @options = options

      @app_url = options[:app_url] || 'https://app.fera.ai'
      @api_url = options[:api_url] || 'https://api.fera.ai'
    end

    def revoke_token!(auth_token)
      previous_site = Base.site

      Base.site = @app_url

      body = { client_id: @client_id, client_secret: @client_secret, token: auth_token }

      result = Base.connection.post("#{ @app_url }/oauth/revoke", body.to_json)

      Base.site = previous_site

      result
    end

    def decode_jwt(jwt)
      JWT.decode(jwt, @client_secret, true).try(:first).to_h.with_indifferent_access
    rescue StandardError
      nil
    end
  end
end
