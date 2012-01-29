require 'faraday_middleware/response_middleware'

module FaradayMiddleware
  # Public: Restore marshalled Ruby objects in response bodies.
  class ParseMarshal < ResponseMiddleware
    define_parser { |body|
      ::Marshal.load body unless body.empty?
    }
  end
end

# deprecated alias
Faraday::Response::ParseMarshal = FaradayMiddleware::ParseMarshal
