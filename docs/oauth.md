# OAuth Middleware for token authentication

Available middleware:

* FaradayMiddleware::OAuth
* FaradayMiddleware::OAuth2

Example use (OAuth 2):

```rb
connection = Faraday.new('http://example.com/api') do |conn|
  conn.request :oauth2, 'token'
  conn.adapter Faraday.default_adapter
end
```

This will cause the 'token' to be inserted in both the query params (as `access_token`) and headers (as `Token token=<token_value>`).

As of FaradayMiddleware 0.11, you can specify the `token_type` option as `:bearer`:

```rb
connection = Faraday.new('http://example.com/api') do |conn|
  conn.request :oauth2, 'token', token_type: :bearer
  conn.adapter Faraday.default_adapter
end
```

This will cause the token to be inserted ONLY as a header (as `Bearer <token_value>`), which is more standard-compliant.

## DEPRECATION WARNING

Inserting the token as a parameter is now considered a security issue, therefore the next major release of Faraday will only add tokens on headers.
