require 'faraday'

module Faraday
  class Response::ParseXml < Response::Middleware
    begin
      require 'multi_xml'
    rescue LoadError, NameError => error
      self.load_error = error
    end

    def parse(body)
      ::MultiXml.parse(body)
    end
  end
end
