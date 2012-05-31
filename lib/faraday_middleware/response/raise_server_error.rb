require 'faraday'

module FaradayMiddleware
  # Public: Raise exceptions on 400's and 500's from server.
  class RaiseServerError < Faraday::Response::Middleware

    # Public: The default exception class raised when encountering an error
    class ServerError < StandardError
      attr_accessor :env
      def initialize(desc, env)
        @env = env
        super(desc)
      end
    end

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
      420 => "Enhance Your Calm",
      422 => 'Unprocessable Entity',
      423 => 'Locked',
      424 => 'Failed Dependency',
      426 => 'Upgrade Required',
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

    attr_accessor :error_class

    class << self
      attr_accessor :error_class
    end

    dependency do
      self.error_class = ServerError
    end

    def initialize(app = nil, options = {})
      super(app)
      self.error_class = options[:error_class] || self.class.error_class
    end

    def on_complete(env)
      return unless HTTP_STATUS_CODES.keys.include?(env[:status].to_i)

      raise error_class.new("#{env[:status]} #{HTTP_STATUS_CODES[env[:status].to_i]}", env)
    end

  end
end