require 'helper'
require 'faraday_middleware/response/normalize_utf'

describe FaradayMiddleware::NormalizeUtf, :type => :response, :test_date => :normalization do

  context "with no type matching" do
    it "doesn't change nil body" do
      expect(process(nil).body).to be_nil
    end

    it "doesn't change empty body" do
      expect(process('').body).to eq('')
    end
  end

  context "with test data" do
    it 'nfc normalization' do
      test_data do |c1, c2, c3, c4, c5|
        expect(process(c2).body).to eq(UnicodeUtils.nfc(c1))
        expect(process(c2).body).to eq(UnicodeUtils.nfc(c2))
        expect(process(c2).body).to eq(UnicodeUtils.nfc(c3))
        expect(process(c4).body).to eq(UnicodeUtils.nfc(c4))
        expect(process(c4).body).to eq(UnicodeUtils.nfc(c5))
      end
    end

    it 'nfd normalization' do
      test_data do |c1, c2, c3, c4, c5|
        expect(process(c3).body).to eq(UnicodeUtils.nfd(c1))
        expect(process(c3).body).to eq(UnicodeUtils.nfd(c2))
        expect(process(c3).body).to eq(UnicodeUtils.nfd(c3))
        expect(process(c5).body).to eq(UnicodeUtils.nfd(c4))
        expect(process(c5).body).to eq(UnicodeUtils.nfd(c5))
      end
    end

    it 'nfkc normalization' do
      test_data do |c1, c2, c3, c4, c5|
        expect(process(c4).body).to eq(UnicodeUtils.nfkc(c1))
        expect(process(c4).body).to eq(UnicodeUtils.nfkc(c2))
        expect(process(c4).body).to eq(UnicodeUtils.nfkc(c3))
        expect(process(c4).body).to eq(UnicodeUtils.nfkc(c4))
        expect(process(c4).body).to eq(UnicodeUtils.nfkc(c5))
      end
    end

    it 'nfkd normalization' do
      test_data do |c1, c2, c3, c4, c5|
        expect(process(c5).body).to eq(UnicodeUtils.nfkd(c1))
        expect(process(c5).body).to eq(UnicodeUtils.nfkd(c2))
        expect(process(c5).body).to eq(UnicodeUtils.nfkd(c3))
        expect(process(c5).body).to eq(UnicodeUtils.nfkd(c4))
        expect(process(c5).body).to eq(UnicodeUtils.nfkd(c5))
      end
    end
  end

end
