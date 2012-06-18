require 'helper'
require 'faraday_middleware/response/parse_dates'
require 'json'

describe FaradayMiddleware::ParseDates, :type => :response do
  let(:parsed){
    if RUBY_VERSION > "1.9"
      "2012-02-01 13:14:15 UTC"
    else
      "Wed Feb 01 13:14:15 UTC 2012"
    end
  }

  it "should parse dates" do
    process({"x" => "2012-02-01T13:14:15Z"}).body["x"].to_s.should == parsed
  end

  it "should parse nested dates in hash" do
    process({"x" => {"y" => "2012-02-01T13:14:15Z"}}).body["x"]["y"].to_s.should == parsed
  end

  it "should parse nested dates in arrays" do
    process({"x" => [{"y" =>"2012-02-01T13:14:15Z"}]}).body["x"][0]["y"].to_s.should == parsed
  end

  it "should not blow up on empty body" do
    process(nil).body.should == nil
  end

  it "should leave arrays with ids alone" do
    process({"x" => [1,2,3]}).body.should == {"x" => [1,2,3]}
  end

  it "should not parse date-like things" do
    process({"x" => "2012-02-01T13:14:15Z bla"}).body["x"].to_s.should ==
      "2012-02-01T13:14:15Z bla"
    process({"x" => "12012-02-01T13:14:15Z"}).body["x"].to_s.should ==
      "12012-02-01T13:14:15Z"
    process({"x" => "2012-02-01T13:14:15Z\nfoo"}).body["x"].to_s.should ==
      "2012-02-01T13:14:15Z\nfoo"
  end
end
