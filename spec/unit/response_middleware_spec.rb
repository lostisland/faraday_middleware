# frozen_string_literal: true

require 'helper'
require 'faraday_middleware/response_middleware'

RSpec.describe FaradayMiddleware::ResponseMiddleware do
  describe '.define_parser' do
    it 'raises error when missing parser and block' do
      expect do
        described_class.define_parser
      end.to raise_error(ArgumentError)
    end

    it 'raises no error when given block' do
      expect do
        described_class.define_parser {}
      end.not_to raise_error
    end

    it 'raises no error when given a parser' do
      expect do
        described_class.define_parser(double)
      end.not_to raise_error
    end
  end
end
