require File.expand_path('../lib/faraday_middleware/version', __FILE__)

Gem::Specification.new do |spec|
  spec.add_dependency 'faraday', ['>= 0.7.4', '< 0.9']
  spec.add_development_dependency 'multi_xml', '~> 0.2'
  spec.add_development_dependency 'rake', '~> 0.9'
  spec.add_development_dependency 'hashie', '~> 1.2'
  spec.add_development_dependency 'rash', '~> 0.3'
  spec.add_development_dependency 'rspec', '~> 2.6'
  spec.add_development_dependency 'simple_oauth', '~> 0.1'
  spec.add_development_dependency 'rack-cache', '~> 1.1'
  spec.authors = ["Erik Michaels-Ober", "Wynn Netherland"]
  spec.description = %q{Various middleware for Faraday}
  spec.email = ['sferik@gmail.com', 'wynn.netherland@gmail.com']
  spec.files = `git ls-files`.split("\n")
  spec.homepage = 'https://github.com/pengwynn/faraday_middleware'
  spec.licenses = ['MIT']
  spec.name = 'faraday_middleware'
  spec.require_paths = ['lib']
  spec.required_rubygems_version = Gem::Requirement.new('>= 1.3.6')
  spec.summary = spec.description
  spec.test_files  = `git ls-files -- {test,spec,features}/*`.split("\n")
  spec.version  = FaradayMiddleware::VERSION
end
