# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'faraday_middleware/version'

Gem::Specification.new do |spec|
  spec.add_dependency 'faraday', ['>= 0.7.4', '< 0.10']
  spec.add_development_dependency 'bundler', '~> 1.0'
  spec.authors = ["Erik Michaels-Ober", "Wynn Netherland"]
  spec.description = %q{Various middleware for Faraday}
  spec.email = ['sferik@gmail.com', 'wynn.netherland@gmail.com']
  spec.files = %w(CHANGELOG.md CONTRIBUTING.md LICENSE.md README.md Rakefile faraday_middleware.gemspec)
  spec.files += Dir.glob("lib/**/*.rb")
  spec.files += Dir.glob("spec/**/*")
  spec.homepage = 'https://github.com/lostisland/faraday_middleware'
  spec.licenses = ['MIT']
  spec.name = 'faraday_middleware'
  spec.require_paths = ['lib']
  spec.required_rubygems_version = '>= 1.3.5'
  spec.summary = spec.description
  spec.test_files += Dir.glob("spec/**/*")
  spec.version = FaradayMiddleware::VERSION
end
