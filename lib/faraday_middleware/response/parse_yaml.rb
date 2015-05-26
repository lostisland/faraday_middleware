require 'faraday_middleware/response_middleware'

module FaradayMiddleware
  # Public: Parse response bodies as YAML.
  #
  # Warning: this uses `YAML.load()` by default and as such is not safe against
  # code injection or DoS attacks. If you're loading resources from an
  # untrusted host or over HTTP, you should subclass this middleware and
  # redefine it to use `safe_load()` if you're using a Psych version that
  # supports it:
  #
  #     class SafeYaml < FaradayMiddleware::ParseYaml
  #       define_parser do |body|
  #         YAML.safe_load(body)
  #       end
  #     end
  #
  #     Faraday.new(..) do |config|
  #       config.use SafeYaml
  #       ...
  #     end
  class ParseYaml < ResponseMiddleware
    dependency 'yaml'

    define_parser do |body|
      ::YAML.load body
    end
  end
end

# deprecated alias
Faraday::Response::ParseYaml = FaradayMiddleware::ParseYaml
