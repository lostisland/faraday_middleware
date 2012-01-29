require 'faraday_middleware/response_middleware'

module FaradayMiddleware
  # Public: Parse response bodies as YAML.
  class ParseYaml < ResponseMiddleware
    dependency 'yaml'

    define_parser { |body| ::YAML.load body }
  end
end

# deprecated alias
Faraday::Response::ParseYaml = FaradayMiddleware::ParseYaml
