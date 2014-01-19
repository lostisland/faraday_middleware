source 'https://rubygems.org'

gem 'faraday', :git => 'https://github.com/lostisland/faraday'
gem 'jruby-openssl', :platforms => :jruby
gem 'json', :platforms => [:jruby, :ruby_18]
gem 'multi_xml', '>= 0.5.3'
gem 'hashie', '>= 1.2'
gem 'rack-cache', '>= 1.1'
gem 'rake', '>= 0.9'
gem 'rash', '>= 0.3'
gem 'simple_oauth', '>= 0.1'

group :test do
  gem 'cane', '>= 2.2.2', :platforms => :mri_19
  gem 'rspec', '>= 2.11'
  gem 'simplecov'
end

platforms :rbx do
  gem 'rubysl-base64', '~> 2.0'
  gem 'rubysl-json', '~> 2.0'
  gem 'rubysl-singleton', '~> 2.0'
end

gemspec
