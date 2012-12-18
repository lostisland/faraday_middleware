require 'faraday'

module FaradayMiddleware
  class MultipartRelated < Faraday::Middleware
    CONTENT_TYPE = 'Content-Type'.freeze
    MIME_TYPE = 'multipart/related'.freeze
    
    def call(env)
      env[:request][:boundary] ||= Faraday::Request::Multipart::DEFAULT_BOUNDARY
      env[:request_headers][CONTENT_TYPE] = "#{MIME_TYPE};boundary=#{env[:request][:boundary]}"
      env[:body] = Faraday::Request::Multipart.new.create_multipart(env, env[:body].map { |part| [nil, part]})
      
      @app.call env
    end
  end

end
