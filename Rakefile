if defined? RUBY_ENGINE and 'ruby' == RUBY_ENGINE and RUBY_VERSION.index('1.9') == 0
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
    '--gte=coverage/covered_percent,99',
    '--max-violations=0'
end
