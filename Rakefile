#!/usr/bin/env rake

task :default => [:enable_coverage, :spec, :test]

require 'bundler'
Bundler::GemHelper.install_tasks

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec)

task :enable_coverage do
  ENV['COVERAGE'] = 'yes' unless ENV['CI']
end
