require "helper"
require "faraday_middleware/request/limit_size"

describe FaradayMiddleware::LimitSize, :type => :request do

  let(:env) { double(:env, :url => url) }
  let(:url) { double(:url, :query => query) }

  describe "limiting query length" do

    let(:middleware) { described_class.new(proc {}, :max_query_length => 5) }

    context "when the query is not too long" do

      let(:query) { "id=1" }

      it "does not raise an error" do
        expect { middleware.call(env) }.not_to raise_error
      end

    end

    context "when the query is too long" do

      let(:query) { "id=1&other=fooooooooooooooooooo" }

      it "raises an error" do
        expect { middleware.call(env) }.to raise_error(FaradayMiddleware::LimitSize::QueryTooLong)
      end

    end

  end

end
