deprecation_warning = lambda { |old, new, trace|
  warn "Deprecation warning: #{old} is deprecated; use #{new}"
  warn trace[0,10].join("\n") if $DEBUG
}

Faraday::Request.extend Module.new {
  legacy = [:OAuth, :OAuth2]
  define_method(:const_missing) { |const|
    if legacy.include? const
      klass = FaradayMiddleware.const_get(const)
      deprecation_warning.call "Faraday::Request::#{const}", klass.name, caller
      const_set const, klass
    else
      super
    end
  }
}

Faraday::Response.extend Module.new {
  legacy = [:Mashify, :Rashify, :ParseJson, :ParseMarshal, :ParseXml, :ParseYaml]
  define_method(:const_missing) { |const|
    if legacy.include? const
      klass = FaradayMiddleware.const_get(const)
      deprecation_warning.call "Faraday::Response::#{const}", klass.name, caller
      const_set const, klass
    else
      super
    end
  }
}
