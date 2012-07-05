require 'faraday'

module FaradayMiddleware
  # Request middleware that signs the request with the signature gem.
  #
  # Adds authentication params based on a HMAC signature generated from a
  # combination of the secret, token, and body supplied.  See the signature
  # gem for more information on how to verify the signature on the
  # receiving end.
  #
  # The body must be a hash for a signature to be generated.
  class Signature < Faraday::Middleware
    dependency 'signature'

    def initialize(app, key, secret)
      super(app)

      @key = key
      @secret = secret

      raise ArgumentError, "Both :key and :secret are required" unless @key && @secret
    end

    def call(env)
      if env[:body] && !env[:body].respond_to?(:to_str)
        auth_hash = ::Signature::Request.new(env[:method].to_s.upcase, env[:url].path.to_s, env[:body]).sign(::Signature::Token.new(@key, @secret))
        env[:body] = env[:body].merge(auth_hash)
      end

      @app.call(env)
    end
  end

end
