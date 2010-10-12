require File.expand_path("../lib/faraday_middleware/version", __FILE__)

Gem::Specification.new do |s|
  s.add_development_dependency('hashie', ['~> 0.4.0'])
  s.add_development_dependency('json', ['~> 1.4.6'])
  s.add_development_dependency('shoulda', ['~> 2.11.3'])
  s.add_development_dependency('rake', ['~> 0.8.7'])
  s.add_runtime_dependency('faraday', ['~> 0.4.5'])
  s.add_runtime_dependency('hashie', ['~> 0.4.0'])
  s.add_runtime_dependency('multi_json', ['~> 0.0.4'])
  s.add_runtime_dependency('multi_xml', ['~> 0.1.0'])
  s.add_runtime_dependency('oauth2', ['~> 0.0.13'])
  s.authors = ["Wynn Netherland"]
  s.description = %q{Various middleware for Faraday}
  s.email = ['wynn.netherland@gmail.com']
  s.executables = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.extra_rdoc_files = ["README.md"]
  s.files = `git ls-files`.split("\n")
  s.homepage = 'http://wynnnetherland.com/projects/faraday-middleware/'
  s.name = 'faraday_middleware'
  s.platform = Gem::Platform::RUBY
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.required_rubygems_version = ">= 1.3.6"
  s.summary = %q{Various middleware for Faraday}
  s.test_files = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.version = FaradayMiddleware::VERSION
end
