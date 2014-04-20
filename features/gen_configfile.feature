Feature: Generate Functionality with Configuration File
	In order to generate a properly formatted plist mobileconfig with less typing
	As a CLI
	Some basic inputs are taken from a config file, if available

	Background:
		Given a file named "ca.crt" with:
			"""
			Contents of CA file
			With newlines
			And more newlines
			That should appear as one line
			"""
		And a file named "p12file.p12" with:
			"""
			p12file that should appear
			In base64 encoding as <data/>
			"""

	Scenario: A configuration file supplied should be read, without the need for required flags.
		Given a file named ".ovpnmcgen.rb.yml" with:
			"""
			host: aruba.cucumber.org
			"""
		When I run `ovpnmcgen.rb g cucumber aruba`
		Then the output should contain "error: "
		And the output should not contain "error: Host"

	Scenario: Flags should override configuration file options.
		Given a file named ".ovpnmcgen.rb.yml" with:
			"""
			host: file.org
			no_vod: true
			"""
		When I run `ovpnmcgen.rb g --host aruba.cucumber.org --cafile ca.crt --vod --p12file p12file.p12 cucumber aruba`
		Then the output should match:
			"""
			<key>remote</key>
			\s*<string>aruba.cucumber.org 1194 udp</string>
			"""
		And the output should match:
			"""
			<key>OnDemandEnabled</key>
			\s*<integer>1</integer>
			"""
		And the output should not match:
			"""
			<key>remote</key>
			\s*<string>file.org 1194 udp</string>
			"""

	Scenario: Battle between no-vod in the configuration file and the vod flag default.
		Given a file named ".ovpnmcgen.rb.yml" with:
			"""
			no_vod: false
			"""
		When I run `ovpnmcgen.rb g --host aruba.cucumber.org --cafile ca.crt --p12file p12file.p12 cucumber aruba`
		Then the output should match:
			"""
			<key>OnDemandEnabled</key>
			\s*<integer>1</integer>
			"""

	Scenario: no_vod true in the configuration file.
		Given a file named ".ovpnmcgen.rb.yml" with:
			"""
			no_vod: true
			"""
		When I run `ovpnmcgen.rb g --host aruba.cucumber.org --cafile ca.crt --p12file p12file.p12 cucumber aruba`
		Then the output should match:
			"""
			<key>OnDemandEnabled</key>
			\s*<integer>0</integer>
			"""

	Scenario: ENV variables set here should work.
		Given I set the environment variable "OG_HOST" to "env.org"
		When I run `/usr/bin/env`
		Then the output should contain "OG_HOST=env.org"

	Scenario: ENV variables should override configuration file options.
		Given a file named ".ovpnmcgen.rb.yml" with:
			"""
			host: file.org
			"""
		And I set the environment variable "OG_HOST" to "env.org"
		When I run `ovpnmcgen.rb g --cafile ca.crt --p12file p12file.p12 cucumber aruba`
		Then the output should match:
			"""
			<key>remote</key>
			\s*<string>env.org 1194 udp</string>
			"""
		And the output should not match:
			"""
			<key>remote</key>
			\s*<string>file.org 1194 udp</string>
			"""

	Scenario: Flags should overrride ENV variables, and should also override configuration file options.
		Given a file named ".ovpnmcgen.rb.yml" with:
			"""
			host: file.org
			"""
		And I set the environment variable "OG_HOST" to "env.org"
		When I run `ovpnmcgen.rb g --host aruba.cucumber.org --cafile ca.crt --p12file p12file.p12 cucumber aruba`
		Then the output should match:
			"""
			<key>remote</key>
			\s*<string>aruba.cucumber.org 1194 udp</string>
			"""
		And the output should not match:
			"""
			<key>remote</key>
			\s*<string>env.org 1194 udp</string>
			"""
		And the output should not match:
			"""
			<key>remote</key>
			\s*<string>file.org 1194 udp</string>
			"""
