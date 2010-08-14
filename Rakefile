$LOAD_PATH.unshift File.expand_path("../lib", __FILE__)
require 'rubygems'
require 'bundler'
Bundler.setup
require "bundler/version"
require 'lib/faraday_middleware'

require "rake/testtask"
Rake::TestTask.new(:test) do |test|
  test.ruby_opts = ["-rubygems"] if defined? Gem
  test.libs << "lib" << "test"
  test.pattern = "test/**/*_test.rb"
end
 
desc "Build the gem"
task :build do
  system "gem build faraday_middleware.gemspec"
end
 
desc "Build and release the gem"
task :release => :build do
  system "gem push faraday-middleware-#{FaradayMiddleware::VERSION}.gem"
end

desc "Build and install the gem"
task :install => :build do
  system "sudo gem install faraday-middleware-#{FaradayMiddleware::VERSION}.gem"
end

task :default => :test
