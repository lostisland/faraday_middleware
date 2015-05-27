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

    def utf8_encode(data, charset)
      if RUBY_VERSION.start_with?("1.8")
        # An empty charset means we need to find a meaningful default.
        # ISO-8859-1 is our best guess, because it's a commonly used non-unicode
        # charset, but us-ascii would be the safest bet.
        if charset.empty?
          charset = 'iso-8859-1'
        end

        # For Ruby 1.8, we have to iteratively transcode all keys and values,
        # because JSON.dump can't handle bad encodings.
        if data.is_a? Hash
          transcoded = {}
          data.each do |key, value|
            transcoded[utf8_encode(key, charset)] = utf8_encode(value, charset)
          end
          return transcoded
        elsif data.is_a? Array
          transcoded = []
          data.each do |value|
            transcoded << utf8_encode(value, charset)
          end
          return transcoded
        elsif data.is_a? String
          require 'iconv'
          return ::Iconv.conv('UTF-8//IGNORE', charset, data)
        else
          return data
        end
      else
        # Yay, sanity - make this as little effort as possible.
        if data.respond_to?(:encode)
          # If we don't have a charset, just use whatever is in the string
          # currently. If we do have a charset, we'll have to run some extra
          # checks.
          if not charset.empty?
            # Check passed charset is *understood* by finding it. If this fails,
            # an exception is raised, which it also should be.
            canonical = Encoding.find(charset)

            # Second, ensure the canonical charset and the actual string encoding
            # are identical. If not, we'll have to do a little more than just
            # transcode to UTF-8.
            if canonical != data.encoding
              raise "Provided charset was #{canonical}, but data was #{data.encoding}"
            end
          end
          return data.encode('utf-8')
        else
          return data
        end
      end
    end

    def call(env)
      if process_request?(env)
        body = env[:body]

        # Detect and honour input charset. Basically, all requests without a
        # charset should be considered malformed, but we can make a best guess.
        # Whether the body is a string or another data structure does not
        # matter: all strings *contained* within it must be encoded properly.
        charset = get_charset(env)
        body = utf8_encode(body, charset)

        # If the body is a stirng, we assume it's already JSON. No further
        # processing is necessary.
        # XXX Is :to_str really a good indicator for Strings? Taken from old
        #     code.
        if not body.respond_to?(:to_str)
          # If body isn't a string yet, we need to encode it. We also know it's
          # then going to be UTF-8, because JSON defaults to that.
          # Thanks to utf8_encode above, JSON.dump should not have any issues here.
          body = ::JSON.dump(body)
        end

        env[:body] = body

        # We'll add a content length, because otherwise we're relying on every
        # component down the line properly interpreting UTF-8 - that can fail.
        env[:request_headers][CONTENT_LENGTH] ||= env[:body].bytesize

        # Always base the encoding we're sending in the content type header on
        # the string encoding.
        env[:request_headers][CONTENT_TYPE] = MIME_TYPE_UTF8
      end
      @app.call env
    end

    def process_request?(env)
      type = request_type(env)
      has_body?(env) and (type.empty? or type == MIME_TYPE)
    end

    def get_charset(env)
      enc = env[:request_headers][CONTENT_TYPE].to_s
      enc = enc.split(';', 2).last if enc.index(';')
      enc = enc.split('=', 2).last if enc.index('=')
      return enc
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
