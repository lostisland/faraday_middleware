require 'faraday'

module Faraday
  class Response::ParseJson < Response::Middleware
    begin
      require 'multi_json'
    rescue LoadError, NameError => error
      self.load_error = error
    end

    def parse(body)
      case body
      when ''
        nil
      when 'true'
        true
      when 'false'
        false
      else
        ::MultiJson.decode(body)
      end
    end
  end
end
