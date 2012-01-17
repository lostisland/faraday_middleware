require 'faraday'

module FaradayMiddleware
  class ParseMarshal < Faraday::Response::Middleware

    def parse(body)
      ::Marshal.load(body)
    end
  end
end
