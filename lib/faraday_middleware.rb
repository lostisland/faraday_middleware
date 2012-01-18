require 'faraday'

module FaradayMiddleware
  class << self
    middleware = {
      :OAuth        => 'request/oauth',
      :OAuth2       => 'request/oauth2',
      :EncodeJson   => 'request/encode_json',
      :Mashify      => 'response/mashify',
      :Rashify      => 'response/rashify',
      :ParseJson    => 'response/parse_json',
      :ParseXml     => 'response/parse_xml',
      :ParseMarshal => 'response/parse_marshal',
      :ParseYaml    => 'response/parse_yaml',
      :Caching      => 'response/caching',
      :RackCompatible  => 'rack_compatible'
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

  if Faraday.respond_to? :register_middleware
    Faraday.register_middleware :request,
      :oauth    => lambda { OAuth },
      :oauth2   => lambda { OAuth2 },
      :json     => lambda { EncodeJson }

    Faraday.register_middleware :response,
      :mashify  => lambda { Mashify },
      :rashify  => lambda { Rashify },
      :json     => lambda { ParseJson },
      :json_fix => lambda { ParseJson::MimeTypeFix },
      :xml      => lambda { ParseXml },
      :marshal  => lambda { ParseMarshal },
      :yaml     => lambda { ParseYaml },
      :caching  => lambda { Caching }
  end
end

require 'faraday_middleware/backwards_compatibility'
