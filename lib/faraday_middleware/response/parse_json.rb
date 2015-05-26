require 'faraday_middleware/response_middleware'

module FaradayMiddleware
  # Public: Parse response bodies as JSON.
  class ParseJson < ResponseMiddleware
    dependency do
      require 'json' unless defined?(::JSON)
    end

    define_parser do |body, env|
      # Body is a string, that's good. Now JSON.parse seems to accept strings
      # even when they're not encoded in UTF-8, which is technically a violation
      # of the spec, but it's useful. So let's not enforce UTF-8, unless an
      # appropritate flag is set.
      if strict_encoding?(env) and body.encoding != Encoding::UTF_8
        raise "JSON specs require UTF-8 encoded JSON strings."
      end
      ::JSON.parse body unless body.strip.empty?
    end

    # Public: Override the content-type of the response with "application/json"
    # if the response body looks like it might be JSON, i.e. starts with an
    # open bracket.
    #
    # This is to fix responses from certain API providers that insist on serving
    # JSON with wrong MIME-types such as "text/javascript".
    class MimeTypeFix < ResponseMiddleware
      MIME_TYPE = 'application/json'.freeze

      def process_response(env)
        old_type = env[:response_headers][CONTENT_TYPE].to_s
        new_type = MIME_TYPE.dup
        new_type << ';' << old_type.split(';', 2).last if old_type.index(';')
        env[:response_headers][CONTENT_TYPE] = new_type
      end

      BRACKETS = %w- [ { -
      WHITESPACE = [ " ", "\n", "\r", "\t" ]

      def parse_response?(env)
        super and BRACKETS.include? first_char(env[:body])
      end

      def first_char(body)
        idx = -1
        begin
          char = body[idx += 1]
          char = char.chr if char
        end while char and WHITESPACE.include? char
        char
      end
    end
  end
end

# deprecated alias
Faraday::Response::ParseJson = FaradayMiddleware::ParseJson
