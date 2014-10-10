require 'helper'
require 'faraday_middleware/response/follow_redirects'

describe FaradayMiddleware::FollowRedirects do
  it "redirects" do
    stub_request(:get, "http://facebook.com").to_return(
      :status => 302,
      :headers => {  "Location" => "http://www.facebook.com/" })
    stub_request(:get, "http://www.facebook.com/").to_return(
      :status => 302,
      :headers => { "Location" => "https://www.facebook.com/" })
    stub_request(:get, "https://www.facebook.com/")

    connection = Faraday.new do |conn|
      conn.use FaradayMiddleware::FollowRedirects
      conn.adapter Faraday.default_adapter
    end

    response = connection.get "http://facebook.com"
    expect(response.env[:url].to_s).to eq("https://www.facebook.com/")
  end
end
