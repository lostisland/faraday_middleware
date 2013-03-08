require 'faraday_middleware/response_middleware'

module FaradayMiddleware
  # Public: Parse response bodies as Message Pack.
  class ParseMessagePack < ResponseMiddleware
    dependency 'msgpack'

    define_parser do |body|
      ::MessagePack.unpack(body) if body.length > 0
    end
  end
end
