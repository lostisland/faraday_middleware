require 'faraday'

module FaradayMiddleware
  # Request middleware that encodes the body as JSON.
  #
  # Processes only requests with matching Content-type or those without a type.
  # If a request doesn't have a type but has a body, it sets the Content-type
  # to JSON MIME-type.
  #
  # Doesn't try to encode bodies that already are in string form.
  class EncodeJson < Faraday::Middleware
    CONTENT_TYPE   = 'Content-Type'.freeze
    CONTENT_LENGTH = 'Content-Length'.freeze
    MIME_TYPE      = 'application/json'.freeze
    MIME_TYPE_UTF8 = 'application/json; charset=utf-8'.freeze

    dependency do
      require 'json' unless defined?(::JSON)
    end

    def call(env)
      if process_request?(env)
        body = env[:body]

        # XXX Is :to_str really a good indicator for Strings? Taken from old
        # code.
        if body.respond_to?(:to_str)
          # If the body is a string, we assume it's already JSON. Any non-
          # unicode encoding must be forcibly converted to unicode; we'll
          # assume UTF-8 is best.
          # In fact, ruby/faraday/middleware seems to convert non-utf-8 unicode
          # to UTF-8 at some point anyway, so we'll forcibly re-encode
          # everything to utf-8.
          body.encode!('UTF-8')
        else
          # If body isn't a string yet, we need to encode it. We also know it's
          # then going to be UTF-8, because JSON defaults to that.
          body = encode(body)
        end

        env[:body] = body

        # We'll add a content length, because otherwise we're relying on every
        # component down the line properly interpreting UTF-8 - that can fail.
        env[:request_headers][CONTENT_LENGTH] ||= env[:body].bytesize

        # Always base the encoding we're sending in the content type header on
        # the string encoding.
        env[:request_headers][CONTENT_TYPE] ||= MIME_TYPE_UTF8
      end
      @app.call env
    end

    def encode(data)
      ::JSON.dump data
    end

    def process_request?(env)
      type = request_type(env)
      has_body?(env) and (type.empty? or type == MIME_TYPE)
    end

    def has_body?(env)
      body = env[:body] and !(body.respond_to?(:to_str) and body.empty?)
    end

    def request_type(env)
      type = env[:request_headers][CONTENT_TYPE].to_s
      type = type.split(';', 2).first if type.index(';')
      type
    end
  end
end
