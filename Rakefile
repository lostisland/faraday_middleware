# frozen_string_literal: true

ruby_19 = RUBY_VERSION > '1.9'
ruby_mri = !defined?(RUBY_ENGINE) || RUBY_ENGINE == 'ruby'
default_gemfile = ENV['BUNDLE_GEMFILE'] =~ /Gemfile$/

if ruby_19 && ruby_mri && default_gemfile
  task default: %i[enable_coverage spec]
else
  task default: [:spec]
end

require 'bundler'
Bundler::GemHelper.install_tasks

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec)

task :enable_coverage do
  ENV['COVERAGE'] = 'yes'
end
