require 'faraday_middleware/response_middleware'

module FaradayMiddleware
  class ParseHtml < FaradayMiddleware::ResponseMiddleware
    dependency 'nokogiri'

    define_parser { |body|
      Nokogiri::HTML body
    }
  end
end