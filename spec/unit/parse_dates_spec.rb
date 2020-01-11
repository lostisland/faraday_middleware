require 'helper'
require 'faraday_middleware/response/parse_dates'
require 'json'

RSpec.describe FaradayMiddleware::ParseDates, :type => :response do
  let(:parsed){ "2012-02-01 13:14:15 UTC" }

  it "parses dates" do
    expect(process({"x" => "2012-02-01T13:14:15Z"}).body["x"].to_s).to eq(parsed)
    expect(process({"x" => "2012-02-01T15:14:15+02:00"}).body["x"].utc.to_s).to eq(parsed)
    expect(process({"x" => "2012-02-01T11:14:15-0200"}).body["x"].utc.to_s).to eq(parsed)
  end

  it "parses dates with milliseconds" do
    date_str = "2012-02-01T13:14:15.123Z"
    non_zulu_date_str = "2012-02-01T11:14:15.123-02:00"
    expect(process({"x" => date_str}).body["x"]).to eq(Time.parse(date_str))
    expect(process({"x" => non_zulu_date_str}).body["x"]).to eq(Time.parse(date_str))
  end

  it "parses nested dates in hash" do
    expect(process({"x" => {"y" => "2012-02-01T13:14:15Z"}}).body["x"]["y"].to_s).to eq(parsed)
  end

  it "parses nested dates in arrays" do
    expect(process({"x" => [{"y" =>"2012-02-01T13:14:15Z"}]}).body["x"][0]["y"].to_s).to eq(parsed)
  end

  it "returns nil when body is empty" do
    expect(process(nil).body).to eq(nil)
  end

  it "leaves arrays with ids alone" do
    expect(process({"x" => [1,2,3]}).body).to eq({"x" => [1,2,3]})
  end

  it "does not parse date-like things" do
    expect(process({"x" => "2012-02-01T13:14:15Z bla"}).body["x"].to_s).to eq "2012-02-01T13:14:15Z bla"
    expect(process({"x" => "12012-02-01T13:14:15Z"}).body["x"].to_s).to eq "12012-02-01T13:14:15Z"
    expect(process({"x" => "2012-02-01T13:14:15Z\nfoo"}).body["x"].to_s).to eq "2012-02-01T13:14:15Z\nfoo"
  end
end
