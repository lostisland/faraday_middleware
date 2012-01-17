require 'faraday'

module FaradayMiddleware
  class << self
    middleware = {
      :OAuth        => 'request/oauth',
      :OAuth2       => 'request/oauth2',
      :Mashify      => 'response/mashify',
      :Rashify      => 'response/rashify',
      :ParseJson    => 'response/parse_json',
      :ParseXml     => 'response/parse_xml',
      :ParseMarshal => 'response/parse_marshal',
      :ParseYaml    => 'response/parse_yaml'
    }

    # autoload without the autoload
    define_method(:const_missing) { |const|
      if middleware.member? const
        require "faraday_middleware/#{middleware[const]}"
        raise NameError, "missing #{const} middleware" unless const_defined? const
        const_get const
      else
        super
      end
    }
  end
end

require 'faraday_middleware/backwards_compatibility'
