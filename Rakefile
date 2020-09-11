require "bundler/gem_tasks"
require 'cucumber/rake/task'

Cucumber::Rake::Task.new do |t|
	ENV['CUCUMBER_PUBLISH_QUIET'] = 'true'
	t.cucumber_opts = "--format progress --tags 'not @wip'"
end

desc "Run cucumber tests"
task :test => :cucumber

namespace :pre_commit do
	task :ci => [:test]
end

task :default => :test
