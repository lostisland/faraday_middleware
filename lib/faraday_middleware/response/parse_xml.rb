require 'faraday'

module FaradayMiddleware
  class ParseXml < Faraday::Response::Middleware
    dependency 'multi_xml'

    def parse(body)
      ::MultiXml.parse(body)
    end
  end
end
