ruby_19 = RUBY_VERSION > '1.9'
ruby_mri = !defined?(RUBY_ENGINE) || 'ruby' == RUBY_ENGINE
default_gemfile = ENV['BUNDLE_GEMFILE'] =~ /Gemfile$/

begin
  require 'cane/rake_task'
rescue LoadError
  warn "warning: cane not available; skipping quality checks."
else
  desc %(Check code quality metrics with Cane)
  Cane::RakeTask.new(:quality) do |cane|
    cane.abc_max = 15
    cane.style_measure = 110
    cane.max_violations = 0
    cane.add_threshold 'coverage/covered_percent', :>=, 98.5
  end
end

if ruby_19 && ruby_mri && default_gemfile
  task :default => [:enable_coverage, :spec]
  task :default => :quality if defined?(Cane)
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
