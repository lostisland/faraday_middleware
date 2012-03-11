#!/usr/bin/env rake

if defined? RUBY_ENGINE and 'ruby' == RUBY_ENGINE and '1.9.3' == RUBY_VERSION
  task :default => [:enable_coverage, :spec, :test, :quality]
else
  task :default => [:spec, :test]
end

require 'bundler'
Bundler::GemHelper.install_tasks

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec)

task :enable_coverage do
  ENV['COVERAGE'] = 'yes'
end

task :test do
  sh 'ruby', '-Ilib', 'spec/caching_test.rb'
end

task :quality do
  sh 'cane',
    '--style-measure=100',
    '--gte=coverage/covered_percent,99',
    '--max-violations=2' # TODO: remove for cane > 1.0.0
end
