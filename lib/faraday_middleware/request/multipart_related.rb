require 'faraday'

module FaradayMiddleware
  class MultipartRelated < Faraday::Request::UrlEncoded
    self.mime_type = 'multipart/related'.freeze
    
    def call(env)
      match_content_type(env) do |params|
        env[:request] ||= {}
        env[:request][:boundary] ||= Faraday::Request::Multipart::DEFAULT_BOUNDARY
        env[:request_headers][CONTENT_TYPE] += ";boundary=#{env[:request][:boundary]}"
        env[:body] = create_related(env, params)
      end
      @app.call env
    end

    def create_related(env, params)
      Faraday::Request::Multipart.new.create_multipart(env, env[:body].map { |part| [nil, part]})
    end
  end

  def process_request?(env)
    type = request_type(env)
    env[:body].respond_to?(:map) and !env[:body].empty? and (type.empty? or type == self.class.mime_type)
  end

end

