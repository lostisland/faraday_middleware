require "faraday"

module FaradayMiddleware
  class NormalizeUtf < Faraday::Response::Middleware

    TYPES = Set.new [:nfd, :nfc, :nfkd, :nfkc]
    DEFAULT_TYPE = :nfkd

    dependency 'unicode_utils'

    attr_accessor :type

    def initialize(app, type = :nfkd)
      super(app)
      @type =  TYPES.include?(type) ? type : DEFAULT_TYPE
    end

    def call(e)
      @app.call(e) { |env| env.body = UnicodeUtils.send(type, env.body) if env.parse_body? }
    end

  end
end