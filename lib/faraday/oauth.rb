require 'roauth'

module Faraday
  class Request::OAuth < Faraday::Middleware
    def initialize(app, *args)
      @app = app
      @oauth_params = {
        :consumer_secret => args.shift,
        :consumer_key => args.shift,
        :access_key   => args.shift,
        :access_secret   => args.shift
      }
      
    end

    def call(env)
      params = env[:url].query_values || {}
      env[:request_headers].merge!('Authorization' => ROAuth.header(@oauth_params, env[:url], params))
      @app.call env
    end
  end
end
