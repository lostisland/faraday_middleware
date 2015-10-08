require 'helper'
require 'faraday_middleware/response/follow_redirects'

describe FaradayMiddleware::FollowRedirects do
  describe 'when following redirects' do
    let(:max_redirects) { 2 }
    let(:connection) {
      Faraday.new do |conn|
        conn.use FaradayMiddleware::FollowRedirects, :limit => max_redirects
        conn.adapter Faraday.default_adapter
      end
    }

    context 'with fewer than the max redirects' do
      let(:location1) { "http://example.com" }
      let(:location2) { "http://www.facebook.com/" }
      let(:location3) { "https://www.facebook.com/" }

      before do
        stub_request(:get, location1).to_return(
          :status => 302,
          :headers => {  "Location" => location2 })
        stub_request(:get, location2).to_return(
          :status => 302,
          :headers => { "Location" => location3 })
        stub_request(:get, location3)
      end

      it "returns the final response in a redirect chain" do
        response = connection.get location1
        expect(response.env[:url].to_s).to eq(location3)
      end

      it "keeps track of all responses in a redirect chain" do
        response = connection.get location1
        expect(response.env[:redirect_chain].length).to eq(3)
        expect(response.env[:redirect_chain][0].env[:url].to_s).to eq(location1)
        expect(response.env[:redirect_chain][1].env[:url].to_s).to eq(location2)
        expect(response.env[:redirect_chain][2].env[:url].to_s).to eq(location3)
      end
    end

    context 'with more than the max redirects' do
      let(:location1) { "http://example.com" }
      let(:location2) { "http://www.facebook.com/" }
      let(:location3) { "https://www.facebook.com/" }
      let(:location4) { "https://www.google.com/" }
      let(:location5) { "https://www.google.ca/" }

      before do
        stub_request(:get, location1).to_return(
          :status => 302,
          :headers => {  "Location" => location2 })
        stub_request(:get, location2).to_return(
          :status => 302,
          :headers => { "Location" => location3 })
        stub_request(:get, location3).to_return(
          :status => 302,
          :headers => { "Location" => location4 })
        stub_request(:get, location4).to_return(
          :status => 302,
          :headers => { "Location" => location5 })
        stub_request(:get, location5)
      end

      it "raises a RedirectLimitReached error containing the last location" do
        expect {
          connection.get(location1)
        }.to raise_error(FaradayMiddleware::RedirectLimitReached, /#{location4}/)
      end
    end
  end
end
