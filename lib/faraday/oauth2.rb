require 'oauth2'

module Faraday
  class Request::OAuth2 < Faraday::Middleware
    def initialize(app, *args)
      @app = app
      @token = args.shift
    end

    def call(env)
      params = env[:url].query_values || {}
      env[:url].query_values = params.merge('access_token' => @token)
      env[:request_headers].merge!('Authorization' => "Token token=\"#{@token}\"")

      @app.call env
    end
  end
end
