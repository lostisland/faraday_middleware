# Method override

Changes the request method to POST and writes the original HTTP method to the "X-Http-Method-Override" header.

This can be used to work around technical issues with making non-POST requests, e.g. a faulty HTTP client or server router.

This header is recognized in Rack apps by default, courtesy of the [Rack::MethodOverride](https://www.rubydoc.info/github/rack/rack/Rack/MethodOverride) module.

```rb
connection = Faraday.new 'http://example.com/api' do |conn|
  # rewrite all non-GET/POST requests:
  conn.request :method_override

  # rewrite just PATCH and OPTIONS requests:
  conn.request :method_override, rewrite: [:patch, :options]
end

connection.patch('users/12', payload)
#=> sends the request as POST, but with "X-Http-Method-Override: PATCH" header
```
