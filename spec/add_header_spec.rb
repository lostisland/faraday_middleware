require 'helper'
require 'faraday_middleware/request/add_header'

describe FaradayMiddleware::AddHeader do
  let(:subject) { described_class }

  def make_app(*args)
    described_class.new lambda{|env| env}, *args
  end

  it "should add the specified header with the value" do
    env = { :request_headers => Faraday::Utils::Headers.new }

    app = make_app 'X-Restful-API-Key', 'foo'

    app.call env

    env[:request_headers]['X-Restful-API-Key'].should == 'foo'
  end
end
