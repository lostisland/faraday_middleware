# faraday_middleware documentation

This is a collection of middleware for the [Faraday][] project.

Example use:

```rb
require 'faraday_middleware'

connection = Faraday.new 'http://example.com/api' do |conn|
  conn.request :oauth2, 'TOKEN'
  conn.request :json

  conn.response :xml,  :content_type => /\bxml$/
  conn.response :json, :content_type => /\bjson$/

  conn.use :instrumentation
  conn.adapter Faraday.default_adapter
end
```

**Important:** same as with Rack middleware, the order of middleware on
a Faraday stack is significant. General guidelines:

1. put request middleware first, in order of importance;
2. put response middleware second, in the reverse order of importance;
3. ensure that the adapter is always last.

## Request middleware:

* FaradayMiddleware::EncodeJson
* FaradayMiddleware::OAuth
* FaradayMiddleware::OAuth2
* [[FaradayMiddleware::MethodOverride|method override]]

## Response middleware:

* [[Parsing responses]]:
  * FaradayMiddleware::ParseJson
  * FaradayMiddleware::ParseXml
  * FaradayMiddleware::ParseYaml
  * FaradayMiddleware::ParseMarshal
* [[FaradayMiddleware::Caching|Caching]]
* FaradayMiddleware::FollowRedirects
* FaradayMiddleware::Mashify
* FaradayMiddleware::Rashify

## Other middleware:

* [[FaradayMiddleware::Instrumentation|Instrumentation]]
* [[FaradayMiddleware::RackCompatible|Caching]]
* [[FaradayMiddleware::Gzip|Gzip Compression]]

[faraday]: https://github.com/lostisland/faraday#readme

