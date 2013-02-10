require File.expand_path('../lib/faraday_middleware/version', __FILE__)

Gem::Specification.new do |spec|
  spec.add_dependency 'faraday', ['>= 0.7.4', '< 0.9']
  spec.add_development_dependency 'bundler', '~> 1.0'
  spec.authors = ["Erik Michaels-Ober", "Wynn Netherland"]
  spec.description = %q{Various middleware for Faraday}
  spec.email = ['sferik@gmail.com', 'wynn.netherland@gmail.com']
  spec.files = `git ls-files`.split("\n")
  spec.homepage = 'https://github.com/lostisland/faraday_middleware'
  spec.licenses = ['MIT']
  spec.name = 'faraday_middleware'
  spec.require_paths = ['lib']
  spec.required_rubygems_version = Gem::Requirement.new('>= 1.3.6')
  spec.summary = spec.description
  spec.test_files  = `git ls-files -- {test,spec,features}/*`.split("\n")
  spec.version  = FaradayMiddleware::VERSION
end
