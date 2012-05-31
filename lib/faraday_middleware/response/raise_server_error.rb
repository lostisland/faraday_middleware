require 'faraday_middleware/response_error_middleware'

module FaradayMiddleware
  # Public: Raise exceptions on 5xx's from server.
  class RaiseServerError < FaradayMiddleware::ResponseErrorMiddleware

    # Public: The default exception class raised when encountering an error
    class ServerError < ServerResponseError; end

    HTTP_STATUS_CODES = {
      500 => 'Internal Server Error',
      501 => 'Not Implemented',
      502 => 'Bad Gateway',
      503 => 'Service Unavailable',
      504 => 'Gateway Timeout',
      505 => 'HTTP Version Not Supported',
      506 => 'Variant Also Negotiates',
      507 => 'Insufficient Storage',
      510 => 'Not Extended'
    }

    dependency do
      self.error_class = ServerError
      self.status_codes = HTTP_STATUS_CODES
    end

  end
end