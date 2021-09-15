# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'faraday_middleware/version'

Gem::Specification.new do |spec|
  spec.name = 'faraday_middleware'
  spec.version = FaradayMiddleware::VERSION

  spec.summary = 'Various middleware for Faraday'
  spec.authors = ['Erik Michaels-Ober', 'Wynn Netherland']
  spec.email = ['sferik@gmail.com', 'wynn.netherland@gmail.com']
  spec.homepage = 'https://github.com/lostisland/faraday_middleware'
  spec.licenses = ['MIT']

  spec.required_ruby_version = '>= 2.3'

  spec.add_dependency 'faraday', '~> 1.0'

  spec.files = Dir['lib/**/*', 'LICENSE.md', 'README.md']
end
