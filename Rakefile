# frozen_string_literal: true
require "bundler/gem_tasks"
require 'cucumber/rake/task'

Cucumber::Rake::Task.new do |t|
	ENV['CUCUMBER_PUBLISH_QUIET'] = 'true'
	t.cucumber_opts = "--format progress --tags 'not @wip'"
end

desc "Run cucumber tests"
task :test => :cucumber

task :default => :test
