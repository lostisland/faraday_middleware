# Instrumenting requests with Active Support

FaradayMiddleware::Instrumentation uses Active Support to instrument
requests. It records information about each request and time spent
performing it.

```rb
conn.use :instrumentation
```

The default key under which all requests are instrumented is
"request.faraday". You can subscribe to these events and log them
accordingly:

```rb
ActiveSupport::Notifications.subscribe('request.faraday') do |name, start_time, end_time, _, env|
  url = env[:url]
  http_method = env[:method].to_s.upcase
  duration = end_time - start_time
  $stderr.puts '[%s] %s %s (%.3f s)' % [url.host, http_method, url.request_uri, duration]
end
```

