require "bundler/gem_tasks"
require 'cucumber/rake/task'

Cucumber::Rake::Task.new do |t|
end

desc "Run cucumber tests"
task :test => :cucumber

namespace :pre_commit do
	task :ci => [:test]
end

task :default => :test
