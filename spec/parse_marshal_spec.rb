require 'helper'
require 'faraday_middleware/response/parse_marshal'

describe FaradayMiddleware::ParseMarshal, :type => :response do
  it "restores a marshaled dump" do
    process(Marshal.dump(:a => 1)).body.should be_eql(:a => 1)
  end

  it "nulifies blank response" do
    process('').body.should be_nil
  end

  it "chokes on invalid content" do
    expect { process('abc') }.to raise_error(Faraday::Error::ParsingError)
  end
end
