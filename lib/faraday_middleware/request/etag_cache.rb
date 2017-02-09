require 'faraday'

module FaradayMiddleware
  # Request middleware that caches responses based on etags
  # based on https://gist.github.com/2463912
  class EtagCache < Faraday::Middleware
    def initialize(app, options = {})
      @app = app
      @cache = options[:cache] ||
        raise("need :cache option e.g. ActiveSupport::Cache::MemoryStore.new")
      @cache_key_prefix = options.fetch(:cache_key_prefix, :faraday_etags)
    end

    def call(env)
      return @app.call(env) unless [:get, :head].include?(env[:method])
      cache_key = [@cache_key_prefix, env[:url].to_s]

      # send known etag
      if cached = @cache.read(cache_key)
        env[:request_headers]["If-None-Match"] ||= cached[:response_headers]["Etag"]
      end

      @app.call(env).on_complete do
        if cached && env[:status] == 304 # not modified
          env[:body] = cached[:body]
        end

        if env[:status] == 200 && env[:response_headers]["Etag"] # modified and cacheable
          @cache.write(cache_key, env)
        end
      end
    end
  end
end
