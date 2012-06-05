if defined? RUBY_ENGINE and 'ruby' == RUBY_ENGINE and RUBY_VERSION.index('1.9') == 0
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
    '--abc-max=10',
    '--style-measure=100',
    '--gte=coverage/covered_percent,99',
    '--max-violations=2'
end
