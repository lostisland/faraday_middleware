require 'helper'
require 'faraday_middleware/response/parse_marshal'

describe FaradayMiddleware::ParseMarshal, :type => :response do
  it "restores a marshaled dump" do
    expect(process(Marshal.dump(:a => 1)).body).to be_eql(:a => 1)
  end

  it "nulifies blank response" do
    expect(process('').body).to be_nil
  end

  it "chokes on invalid content" do
    expect{ process('abc') }.to raise_error(Faraday::Error::ParsingError)
  end
end
