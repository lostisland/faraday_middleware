module Faraday
  class Response::Parse < Response::Middleware
    begin
      require 'multi_json'
      require 'multi_xml'
    rescue LoadError, NameError => error
      self.load_error = error
    end

    def self.register_on_complete(env)
      env[:response].on_complete do |response|
        response[:body] = begin
          case response[:response_headers]['content-type']
          when /application\/json/
            case response[:body]
            when ''
              nil
            when 'true'
              true
            when 'false'
              false
            else
              ::MultiJson.decode(response[:body])
            end
          when /application\/xml/
            ::MultiXml.parse(response[:body])
          else
            ''
          end
        end
      end
    end

    def initialize(app)
      super
      @parser = nil
    end
  end
end
