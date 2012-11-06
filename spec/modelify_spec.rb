require 'helper'
require 'faraday_middleware/response/modelify'

describe FaradayMiddleware::Modelify do
  class Website < Hashie::Mash; end
  class Contact < Hashie::Mash; end

  context "when used" do
    let(:modelify) do
      described_class.new(nil, {
        models: {
          Website => %w(site sites),
          Contact => %w(person people)
        }
      })
    end

    it "creates a Contact and a Website" do
      data = modelify.on_complete({
        body: {
          "person" => { name: "Andrew", age: 28 },
          "site" => { name: "Google", url: "google.com" }
        }
      })

      expect(data["person"].class).to eq(Contact)
      expect(data["site"].class).to eq(Website)
    end

    it "creates Contacts and Websites" do
      data = modelify.on_complete({
        body: {
          "people" => [
            { name: "Andrew", age: 28 },
            { name: "Ashley", age: 26 }
          ],
          "sites" => [
            { name: "Google", url: "google.com" },
            { name: "Bing", url: "bing.com" }
          ]
        }
      })

      expect(data["people"].length).to eq(2)
      expect(data["people"].first.class).to eq(Contact)
      expect(data["people"].last.class).to eq(Contact)

      expect(data["sites"].length).to eq(2)
      expect(data["sites"].first.class).to eq(Website)
      expect(data["sites"].last.class).to eq(Website)
    end

    it "passes through unknown keys" do
      data = modelify.on_complete({
        body: {
          "address" => {
            street: "Kinzie",
            city: "Chicago",
            state: "Il"
          }
        }
      })

      expect(data['address'].class).to eq(Hash)
    end
  end
end
