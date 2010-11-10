require 'faraday'

module Faraday
  class Response::ParseXml < Response::Middleware
    begin
      require 'multi_xml'
    rescue LoadError, NameError => error
      self.load_error = error
    end

    def self.register_on_complete(env)
      env[:response].on_complete do |response|
        response[:body] = begin
          ::MultiXml.parse(response[:body])
        end
      end
    end

    def initialize(app)
      super
      @parser = nil
    end
  end
end
