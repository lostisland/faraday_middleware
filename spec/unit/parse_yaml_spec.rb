# frozen_string_literal: true

require 'helper'
require 'faraday_middleware/response/parse_yaml'

RSpec.describe FaradayMiddleware::ParseYaml, type: :response do
  context 'no type matching' do
    it "doesn't change nil body" do
      expect(process(nil).body).to be_nil
    end

    it 'returns false for empty body' do
      expect(process('').body).to be false
    end

    it 'parses yaml body' do
      response = process('a: 1')
      expect(response.body).to eq('a' => 1)
      expect(response.env[:raw_body]).to be_nil
    end
  end

  context 'with preserving raw' do
    let(:options) { { preserve_raw: true } }

    it 'parses yaml body' do
      response = process('a: 1')
      expect(response.body).to eq('a' => 1)
      expect(response.env[:raw_body]).to eq('a: 1')
    end

    it 'can opt out of preserving raw' do
      response = process('a: 1', nil, preserve_raw: false)
      expect(response.env[:raw_body]).to be_nil
    end
  end

  context 'with regexp type matching' do
    let(:options) { { content_type: /\byaml$/ } }

    it 'parses json body of correct type' do
      response = process('a: 1', 'application/x-yaml')
      expect(response.body).to eq('a' => 1)
    end

    it 'ignores json body of incorrect type' do
      response = process('a: 1', 'text/yaml-xml')
      expect(response.body).to eq('a: 1')
    end
  end

  it 'chokes on invalid yaml' do
    expect { process('{!') }.to raise_error(Faraday::ParsingError)
  end

  context 'SafeYAML options' do
    let(:body) { 'a: 1' }
    let(:result) { { a: 1 } }
    let(:options) do
      {
        parser_options: {
          symbolize_names: true
        }
      }
    end

    it 'passes relevant options to SafeYAML load' do
      expect(::SafeYAML).to receive(:load)
        .with(body, nil, options[:parser_options])
        .and_return(result)

      response = process(body)
      expect(response.body).to be(result)
    end
  end
end
