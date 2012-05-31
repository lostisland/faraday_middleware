require 'faraday_middleware/response_error_middleware'

module FaradayMiddleware
  # Public: Raise exceptions on 4xx's from server.
  class RaiseClientError < FaradayMiddleware::ResponseErrorMiddleware

    # Public: The default exception class raised when encountering an error
    class ClientError < ServerResponseError; end

    HTTP_STATUS_CODES = {
      400 => 'Bad Request',
      401 => 'Unauthorized',
      402 => 'Payment Required',
      403 => 'Forbidden',
      404 => 'Not Found',
      405 => 'Method Not Allowed',
      406 => 'Not Acceptable',
      407 => 'Proxy Authentication Required',
      408 => 'Request Timeout',
      409 => 'Conflict',
      410 => 'Gone',
      411 => 'Length Required',
      412 => 'Precondition Failed',
      413 => 'Request Entity Too Large',
      414 => 'Request-URI Too Long',
      415 => 'Unsupported Media Type',
      416 => 'Requested Range Not Satisfiable',
      417 => 'Expectation Failed',
      418 => "I'm a Teapot",
      420 => 'Enhance Your Calm',
      422 => 'Unprocessable Entity',
      423 => 'Locked',
      424 => 'Failed Dependency',
      426 => 'Upgrade Required'
    }

    dependency do
      self.error_class = ClientError
      self.status_codes = HTTP_STATUS_CODES
    end

  end
end