source 'https://rubygems.org'

gem 'faraday', '~> 0.7.4'
gem 'hashie', '>= 1.2'
gem 'jruby-openssl', :platforms => :jruby
gem 'json', :platforms => [:jruby, :rbx, :ruby_18]
gem 'multi_xml', '>= 0.5.3'
gem 'rake', '>= 0.9'
gem 'rash', '>= 0.3'
gem 'simple_oauth', '>= 0.1', '< 0.3'

# ruby 1.8.7 compatible
gem 'addressable', '< 2.4.0'
gem 'gyoku', '<= 1.2.3'
gem 'rack-cache', '< 1.3'

group :test do
  gem 'cane', '>= 2.2.2', :platforms => [:mri_19, :mri_20, :mri_21]
  gem 'parallel', '< 1.3.4', :platforms => [:mri_19, :mri_20, :mri_21]
  gem 'rspec', '>= 3'
  gem 'simplecov'
  gem 'webmock'
end

gemspec
