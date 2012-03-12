require 'faraday'

module FaradayMiddleware
  autoload :OAuth,           'faraday_middleware/request/oauth'
  autoload :OAuth2,          'faraday_middleware/request/oauth2'
  autoload :EncodeJson,      'faraday_middleware/request/encode_json'
  autoload :Mashify,         'faraday_middleware/response/mashify'
  autoload :Rashify,         'faraday_middleware/response/rashify'
  autoload :ParseJson,       'faraday_middleware/response/parse_json'
  autoload :ParseXml,        'faraday_middleware/response/parse_xml'
  autoload :ParseMarshal,    'faraday_middleware/response/parse_marshal'
  autoload :ParseYaml,       'faraday_middleware/response/parse_yaml'
  autoload :ParseHtml,       'faraday_middleware/response/parse_html'
  autoload :Caching,         'faraday_middleware/response/caching'
  autoload :RackCompatible,  'faraday_middleware/rack_compatible'
  autoload :FollowRedirects, 'faraday_middleware/response/follow_redirects'
  autoload :Instrumentation, 'faraday_middleware/instrumentation'

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
      :html     => lambda { ParseHtml },
      :caching  => lambda { Caching },
      :follow_redirects => lambda { FollowRedirects }

    Faraday.register_middleware \
      :instrumentation  => lambda { Instrumentation }
  end
end

require 'faraday_middleware/backwards_compatibility'
