# Faraday Middleware

Collection of [Faraday](http://github.com/technoweenie/faraday) middlewares I've been using in some of my API wrappers


## Installation

    sudo gem install faraday_middleware


#### Some examples

Let's decode the response body with [MultiJson](http://github.com/intridea/multi_json)

    conn = Faraday::Connection.new(:url => 'http://api.twitter.com/1') do |builder|
      builder.adapter Faraday.default_adapter
      builder.use Faraday::Response::ParseJson
    end

    resp = conn.get do |req|
      req.url '/users/show.json', :screen_name => 'pengwynn'
    end

    u = resp.body
    u['name']
    # => "Wynn Netherland"


Want to ditch the brackets and use dot notation? [Mashify](http://github.com/intridea/hashie) it!

    conn = Faraday::Connection.new(:url => 'http://api.twitter.com/1') do |builder|
      builder.adapter Faraday.default_adapter
      builder.use Faraday::Response::ParseJson
      builder.use Faraday::Response::Mashify
    end

    resp = conn.get do |req|
      req.url '/users/show.json', :screen_name => 'pengwynn'
    end

    u = resp.body
    u.name
    # => "Wynn Netherland"
