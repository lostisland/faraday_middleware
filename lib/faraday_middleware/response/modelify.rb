# Initialize this middelware with an options hash with the models key being a
# hash whose keys are the class you wish to instantiate and the values an
# array of possible key names in the decoded JSON.
#
#  Faraday.new url do |conn|
#    conn.response :modelify, models: {
#      Website => %w(website websites),
#      Contact => %w(contact contacts)
#    }
#    conn.response :json, content_type: /\bjson$/
#    conn.adapter Faraday.default_adapter
#  end
#
class FaradayMiddleware::Modelify < Faraday::Response::Middleware
  # options:
  #   models: hash of class to an array of JSON key names
  def initialize(app, opts = {})
    super(app)

    # rearrange hash so key => klass for faster lookup
    opts[:models] ||= {}
    @classes = opts[:models].inject({}) do |hsh, (klass, keys)|
      [keys].flatten.each{ |key| hsh[key] = klass }
      hsh
    end
  end

  def parse(body)
    body.inject({}) do |hsh, (key, data)|
      if klass = @classes[key]
        case data
        when Hash
          hsh[key] = klass.new(data)
        when Array
          hsh[key] = data.map{ |i| klass.new(i) }
        end
      else
        hsh[key] = data
      end

      hsh
    end
  end
end
