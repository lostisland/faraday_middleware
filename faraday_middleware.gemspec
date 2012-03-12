require File.expand_path('../lib/faraday_middleware/version', __FILE__)

Gem::Specification.new do |gem|
  gem.add_dependency 'faraday', ['>= 0.7.4', '< 0.9']
  gem.add_development_dependency 'multi_xml', '~> 0.2'
  gem.add_development_dependency 'rake', '~> 0.9'
  gem.add_development_dependency 'hashie', '~> 1.2'
  gem.add_development_dependency 'rash', '~> 0.3'
  gem.add_development_dependency 'rspec', '~> 2.6'
  gem.add_development_dependency 'simple_oauth', '~> 0.1'
  gem.add_development_dependency 'rack-cache', '~> 1.1'
  gem.authors = ["Erik Michaels-Ober", "Wynn Netherland"]
  gem.description = %q{Various middleware for Faraday}
  gem.email = ['sferik@gmail.com', 'wynn.netherland@gmail.com']
  gem.files = `git ls-files`.split("\n")
  gem.homepage = 'https://github.com/pengwynn/faraday_middleware'
  gem.name = 'faraday_middleware'
  gem.require_paths = ['lib']
  gem.required_rubygems_version = Gem::Requirement.new('>= 1.3.6')
  gem.summary = gem.description
  gem.test_files  = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.version  = FaradayMiddleware::VERSION
end
