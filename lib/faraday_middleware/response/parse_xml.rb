require 'faraday_middleware/response_middleware'

module FaradayMiddleware
  class ParseXml < ResponseMiddleware
    dependency 'multi_xml'

    define_parser { |body|
      ::MultiXml.parse(body)
    }
  end
end

# deprecated alias
Faraday::Response::ParseXml = FaradayMiddleware::ParseXml
