ruby_19 = RUBY_VERSION > '1.9'
ruby_mri = !defined?(RUBY_ENGINE) || 'ruby' == RUBY_ENGINE
default_gemfile = ENV['BUNDLE_GEMFILE'] =~ /Gemfile$/

if ruby_19 && ruby_mri && default_gemfile
  task :default => [:enable_coverage, :spec, :quality]
else
  task :default => [:spec]
end

require 'bundler'
Bundler::GemHelper.install_tasks

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec)

task :enable_coverage do
  ENV['COVERAGE'] = 'yes'
end

desc %(Check code quality metrics with Cane)
task :quality do
  sh 'cane',
    '--abc-max=15',
    '--style-measure=110',
    '--gte=coverage/covered_percent,97.55',
    '--max-violations=0'
end
