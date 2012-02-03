require 'helper'
require 'faraday_middleware/response/parse_html'

describe FaradayMiddleware::ParseHtml, :type => :response do
  it "does not choke on invalid xml" do
    ['{!', '"a"', 'true', 'null', '1'].each do |data|
      expect { process(data) }.to_not raise_error(Faraday::Error::ParsingError)
    end
  end
end