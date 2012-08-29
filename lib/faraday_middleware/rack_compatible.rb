require 'stringio'

module FaradayMiddleware
  # Wraps a handler originally written for Rack to make it compatible with Faraday.
  #
  # Experimental. Only handles changes in request headers.
  class RackCompatible
    def initialize(app, rack_handler, *args)
      # tiny middleware that decomposes a Faraday::Response to standard Rack
      # array: [status, headers, body]
      compatible_app = lambda do |env|
        restore_env(env)
        response = app.call(env)
        [response.status, response.headers, Array(response.body)]
      end
      @rack = rack_handler.new(compatible_app, *args)
    end

    def call(env)
      prepare_env(env)
      rack_response = @rack.call(env)
      finalize_response(env, rack_response)
    end

    private

    NonPrefixedHeaders = %w[CONTENT_LENGTH CONTENT_TYPE]

    # faraday to rack-compatible
    def prepare_env(env)
      headers_to_rack(env)
      env_to_rack(env)
    end

    # convert faraday headers to rack env values.
    def headers_to_rack(env)
      env[:request_headers].each do |name, value|
        name = name.upcase.tr('-', '_')
        name = "HTTP_#{name}" unless NonPrefixedHeaders.include? name
        env[name] = value
      end
    end

    # convert faraday env to rack env.
    def env_to_rack(env)
      url = env[:url]
      env['rack.url_scheme'] = url.scheme
      env['PATH_INFO'] = url.path
      env['SERVER_PORT'] = port_for_url(url)
      env['QUERY_STRING'] = url.query
      env['REQUEST_METHOD'] = upcase_request_method(env[:method])

      env['rack.errors'] ||= StringIO.new

      env
    end

    # rack to faraday-compatible
    def restore_env(env)
      restore_headers(env)
      env[:method] = symbol_request_method(env['REQUEST_METHOD'])
      env
    end

    # convert rack env headers to faraday headers.
    def restore_headers(env)
      headers = env[:request_headers]
      headers.clear

      env.each do |name, value|
        next unless String === name
        if NonPrefixedHeaders.include? name or name.index('HTTP_') == 0
          name = name.sub(/^HTTP_/, '').downcase.tr('_', '-')
          headers[name] = value
        end
      end
    end

    def finalize_response(env, rack_response)
      status, headers, body = rack_response
      body = body.inject() { |str, part| str << part }
      headers = Faraday::Utils::Headers.new(headers) unless Faraday::Utils::Headers === headers

      env.update :status => status.to_i,
                 :body => body,
                 :response_headers => headers

      env[:response] ||= Faraday::Response.new(env)
      env[:response]
    end

    def port_for_url(url)
      url.respond_to?(:inferred_port) ? url.inferred_port : url.port
    end

    # Upper-case string request method as used by HTTP / Rack.
    def upcase_request_method(request_method)
      request_method.to_s.upcase
    end

    # Symbol request method as used by Faraday.
    def symbol_request_method(request_method)
      request_method.downcase.to_sym
    end
  end
end
