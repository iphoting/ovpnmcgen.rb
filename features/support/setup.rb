require 'aruba/cucumber'
require 'aruba/jruby'

Before do
	@aruba_timeout_seconds = 60
end if RUBY_PLATFORM == 'java'
