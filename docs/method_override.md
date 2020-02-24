# Method override

Writes the original HTTP method to "X-Http-Method-Override" header and changes the request method to POST.

This can be used to work around technical issues with making non-POST requests, e.g. faulty HTTP client or server router.

This header is recognized in Rack apps by default, courtesy of the [Rack::MethodOverride](http://rack.rubyforge.org/doc/classes/Rack/MethodOverride.html) module.

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
