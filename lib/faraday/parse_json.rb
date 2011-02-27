require 'faraday'

module Faraday
  class Response::ParseJson < Response::Middleware
    begin
      require 'multi_json'
    rescue LoadError, NameError => error
      self.load_error = error
    end

    def on_complete(env)
      env[:body] = begin
        case env[:body]
        when ''
          nil
        when 'true'
          true
        when 'false'
          false
        else
          ::MultiJson.decode(env[:body])
        end
      end
    end
  end
end
