require 'faraday'

class Faraday::Request
  autoload :OAuth2, 'faraday/oauth2'
end

class Faraday::Response
  autoload :Mashify,   'faraday/mashify'
  autoload :ParseJson, 'faraday/parse_json'
  autoload :ParseXml,  'faraday/parse_xml'
end
