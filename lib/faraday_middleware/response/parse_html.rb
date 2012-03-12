require 'faraday_middleware/response_middleware'

module FaradayMiddleware
  class ParseHtml < ResponseMiddleware
    dependency 'nokogiri'

    define_parser { |body|
      ::Nokogiri::Slop(body) unless body.empty?
    }
  end
end

# deprecated alias
Faraday::Response::ParseHtml = FaradayMiddleware::ParseHtml
