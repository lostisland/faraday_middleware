require File.expand_path('../lib/faraday_middleware/version', __FILE__)

Gem::Specification.new do |s|
  s.name = 'faraday_middleware'
  s.summary = %q{Various middleware for Faraday}
  s.description = s.summary

  s.homepage = 'http://wynnnetherland.com/projects/faraday-middleware/'

  s.authors = ["Erik Michaels-Ober", "Wynn Netherland"]
  s.email   = ['sferik@gmail.com', 'wynn.netherland@gmail.com']

  s.version  = FaradayMiddleware::VERSION
  s.platform = Gem::Platform::RUBY

  s.require_paths = ['lib']
  s.files = `git ls-files`.split("\n")
  s.test_files  = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }

  s.required_rubygems_version = Gem::Requirement.new('>= 1.3.6') if s.respond_to? :required_rubygems_version=

  s.add_runtime_dependency('faraday', '~> 0.7.0')
  s.add_development_dependency('rake', '~> 0.8')
  s.add_development_dependency('rspec', '~> 2.5')
  s.add_development_dependency('simplecov', '~> 0.4')
  s.add_development_dependency('rash', '~> 0.3')
  s.add_development_dependency('json_pure', '~> 1.5')
  s.add_development_dependency('multi_json', '~> 1.0')
  s.add_development_dependency('multi_xml', '~> 0.2')
  s.add_development_dependency('oauth2', '~> 0.2')
  s.add_development_dependency('simple_oauth', '~> 0.1')
end
