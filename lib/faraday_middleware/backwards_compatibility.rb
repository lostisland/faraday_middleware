Faraday::Request.extend Module.new {
  legacy = [:OAuth, :OAuth2]
  define_method(:const_missing) { |const|
    if legacy.include? const
      const_set const, FaradayMiddleware.const_get(const)
    else
      super
    end
  }
}

Faraday::Response.extend Module.new {
  legacy = [:Mashify, :Rashify, :ParseJson, :ParseMarshal, :ParseXml, :ParseYaml]
  define_method(:const_missing) { |const|
    if legacy.include? const
      const_set const, FaradayMiddleware.const_get(const)
    else
      super
    end
  }
}
