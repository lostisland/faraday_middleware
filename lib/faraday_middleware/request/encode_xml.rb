# frozen_string_literal: true

require 'faraday'

module FaradayMiddleware
  # Request middleware that encodes the body as XML.
  #
  # Processes only requests with matching Content-type or those without a type.
  # If a request doesn't have a type but has a body, it sets the Content-type
  # to XML MIME-type.
  #
  # Doesn't try to encode bodies that already are in string form.
  class EncodeXml < Faraday::Middleware
    CONTENT_TYPE = 'Content-Type'
    MIME_TYPE    = 'application/xml'

    dependency do
      require 'gyoku' unless defined?(::Gyoku)
    end

    def call(env)
      match_content_type(env) do |data|
        env[:body] = encode data
      end
      @app.call env
    end

    def encode(data)
      ::Gyoku.xml(data, key_converter: :none)
    end

    def match_content_type(env)
      return unless process_request?(env)

      env[:request_headers][CONTENT_TYPE] ||= MIME_TYPE
      yield env[:body] unless env[:body].respond_to?(:to_str)
    end

    def process_request?(env)
      type = request_type(env)
      has_body?(env) && (type.empty? or type == MIME_TYPE)
    end

    def has_body?(env)
      (body = env[:body]) && !(body.respond_to?(:to_str) && body.empty?)
    end

    def request_type(env)
      type = env[:request_headers][CONTENT_TYPE].to_s
      type = type.split(';', 2).first if type.index(';')
      type
    end
  end
end
