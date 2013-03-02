if ENV['COVERAGE']
  require 'simplecov'

  SimpleCov.formatter = Class.new do
    def format(result)
      SimpleCov::Formatter::HTMLFormatter.new.format(result) unless ENV['CI']
      File.open('coverage/covered_percent', 'w') do |f|
        f.puts result.source_files.covered_percent.to_i
      end
    end
  end

  SimpleCov.start do
    # add_filter 'faraday_middleware.rb'
    add_filter 'backwards_compatibility.rb'
  end
end

require 'rspec'

module ResponseMiddlewareExampleGroup
  def self.included(base)
    base.let(:options) { Hash.new }
    base.let(:headers) { Hash.new }
    base.let(:middleware) {
      described_class.new(lambda {|env|
        Faraday::Response.new(env)
      }, options)
    }
  end

  def process(body, content_type = nil, options = {})
    env = {
      :body => body, :request => options,
      :response_headers => Faraday::Utils::Headers.new(headers)
    }
    env[:response_headers]['content-type'] = content_type if content_type
    middleware.call(env)
  end
end

module ResponseNormalization
  def normalization_test_txt
    @normalization_test_txt ||= File.join File.dirname(__FILE__), 'data', 'NormalizationTest.txt'
  end

  def test_data
    File.open(normalization_test_txt, "r:utf-8:-") do |input|
      input.each_line do |line|
        line = $1.strip if line =~ /^([^#]*)#/

        next if line.empty? || line =~ /^@Part/

        columns = line.split(';').map do |column|
          str = String.new.force_encoding(Encoding::UTF_8)
          column.split(' ').reduce(str) { |a, c| a << c.strip.to_i(16); a }
        end

        yield *columns if block_given?
      end
    end
  end
end

RSpec.configure do |config|
  config.include ResponseMiddlewareExampleGroup, :type => :response
  config.include ResponseNormalization, :test_date => :normalization

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
