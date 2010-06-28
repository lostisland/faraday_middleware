require 'bundler'
require 'bundler/version'
require 'lib/faraday_middleware'

Gem::Specification.new do |s|
  s.name = %q{faraday-middleware}
  s.version = FaradayMiddleware::VERSION
  s.platform    = Gem::Platform::RUBY
  s.required_rubygems_version = ">= 1.3.6"
  s.authors = ["Wynn Netherland"]
  s.date = %q{2010-06-27}
  s.description = %q{Various middleware for Faraday}
  s.email = %q{wynn.netherland@gmail.com}
  s.files = Dir.glob("{lib}/**/*")
  s.homepage = %q{http://wynnnetherland.com/projects/farday-middleware/}
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.6}
  s.summary = %q{Various middleware for Faraday}
  s.test_files = [
    "test/helper.rb",
    "test/oauth2_test.rb"
  ]

  s.add_bundler_dependencies
end
