require 'faraday'

module FaradayMiddleware
  # A middleware that ensures that the client requests are sent with the
  # headers that encourage servers to send compressed data, and then uncompresses it.
  # The Content-Length will reflect the actual body length.
  class Gzip < Faraday::Middleware
    dependency 'zlib'

    ACCEPT_ENCODING = 'Accept-Encoding'.freeze
    ENCODINGS = 'gzip,deflate'.freeze

    def initialize(app, options = nil)
      @app = app
    end

    def call(env)
      (env[:request_headers] ||= {})[ACCEPT_ENCODING] = ENCODINGS
      @app.call(env).on_complete do |env|
        encoding = env[:response_headers]['content-encoding'].to_s.downcase
        if %w[gzip deflate].include?(encoding)
          case encoding
          when 'gzip'
            args = [StringIO.new(env[:body])]
            args.push(:encoding => 'ASCII-8BIT') if '1.9'.respond_to?(:force_encoding)
            env[:body] = Zlib::GzipReader.new(*args).read
          when 'deflate'
            env[:body] = Zlib::Inflate.inflate(env[:body])
          end
          env[:response_headers].delete('content-encoding')
          env[:response_headers]['content-length'] = env[:body].length
        end
      end
    end

  end
end
