require 'aruba/cucumber'

Before do
	require 'aruba/config/jruby'
	@aruba_timeout_seconds = 60
end if RUBY_PLATFORM == 'java'
