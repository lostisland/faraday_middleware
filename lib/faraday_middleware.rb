require 'faraday'

class Faraday::Request
  autoload :OAuth,  'faraday/request/oauth'
  autoload :OAuth2, 'faraday/request/oauth2'
end

class Faraday::Response
  autoload :Mashify,   'faraday/response/mashify'
  autoload :ParseJson, 'faraday/response/parse_json'
  autoload :ParseXml,  'faraday/response/parse_xml'
end
