# Caching responses

## Simple response body caching

FaradayMiddleware::Caching can be configured with a cache store that
responds to `read`, `write` and `fetch`, such as one of
ActiveSupport::Cache stores.

Example use:

```rb
cache_dir = File.join(ENV['TMPDIR'] || '/tmp', 'cache')

conn.response :caching, :ignore_params => %w[access_token] do  
  ActiveSupport::Cache::FileStore.new cache_dir, :namespace => 'my_namespace',
    :expires_in => 3600  # one hour
end
```

In the above example, the return value of the block represents the cache
store that the middleware will use. It's configured to cache each
GET response for 1 hour.

## Advanced HTTP caching

FaradayMiddleware::RackCompatible can be used to mount [rack-cache][] to
the middleware stack in order to perform caching per HTTP spec.

```rb
conn.use FaradayMiddleware::RackCompatible, Rack::Cache::Context,
  :metastore   => "file:#{cache_dir}/rack/meta",
  :entitystore => "file:#{cache_dir}/rack/body",
  :ignore_headers => %w[Set-Cookie X-Content-Digest]
```

In the above example, the stack is configured to cache successful
responses to disk according to HTTP freshness/expiration information,
and subsequent requests will be validated using information in
Last-Modified/ETag headers.

The `:ignore_headers` option is important to enable caching even if the server
where the data is coming from uses Rack::Cache, too. This is due to
[rack-cache issue #59][bug].

**Using RackCompatible middleware to mount Rack::Cache is kind of a hack**.
Consider using [faraday-http-cache] instead.

  [rack-cache]: http://rtomayko.github.com/rack-cache/
  [bug]: https://github.com/rtomayko/rack-cache/issues/59
  [faraday-http-cache]: https://github.com/plataformatec/faraday-http-cache
