# frozen_string_literal: true

require 'faraday'

module FaradayMiddleware
  class EncodeJsonapi < EncodeJson
    MIME_TYPE       = 'application/vnd.api+json'
  end
end
