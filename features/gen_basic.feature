Feature: Basic Generate Functionality
	In order to generate a properly formatted plist mobileconfig
	As a CLI
	Some basic inputs are required

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

	Scenario: I need help
		When I run `ovpnmcgen.rb help g`
		Then the output should contain "Usage:"

	Scenario: Missing 2 arguments
		When I run `ovpnmcgen.rb g`
		Then the output should contain "error: "
		And the output should contain "arguments"

	Scenario: Missing 1 argument
		When I run `ovpnmcgen.rb g cucumber`
		Then the output should contain "error: "
		And the output should contain "arguments"

	Scenario: Correct number of arguments but missing required flags
		When I run `ovpnmcgen.rb g cucumber aruba`
		Then the output should contain "error: "

	Scenario: Correct arguments but missing required flags, except the host flag.
		When I run `ovpnmcgen.rb g --host aruba.cucumber.org cucumber aruba`
		And the output should not contain "error: Host"
		Then the output should contain "error: "

	Scenario: Correct arguments but missing required flags, except the host, cafile flag.
		When I run `ovpnmcgen.rb g --host aruba.cucumber.org --cafile ca.crt cucumber aruba`
		And the output should not contain "error: Host"
		And the output should not contain "error: cafile"
		Then the output should contain "error: "

	Scenario: Correct arguments will all required flags, host, cafile, p12file.
		When I run `ovpnmcgen.rb g --host aruba.cucumber.org --cafile ca.crt --p12file p12file.p12 cucumber aruba`
		And the output should not contain "error: Host"
		And the output should not contain "error: cafile"
		And the output should not contain "error: PKCS#12"
		Then the output should contain:
			"""
			<?xml version="1.0" encoding="UTF-8"?>
			<!DOCTYPE plist PUBLIC "-//Apple Computer//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
			<plist version="1.0">
			"""
		And the output should match:
			"""
			<key>remote</key>
			\s*<string>aruba.cucumber.org 1194 udp</string>
			"""
		And the output should match:
			"""
			<key>ca</key>
			\s*<string>Contents of CA file\\nWith newlines\\nAnd more newlines\\nThat should appear as one line</string>
			"""
		And the output should match:
			"""
			<key>PayloadCertificateFileName</key>\s*
			\s*<string>cucumber-aruba.p12</string>
			\s*<key>PayloadContent</key>
			\s*<data>
			\s*cDEyZmlsZSB0aGF0IHNob3VsZCBhcHBlYXIKSW4gYmFzZTY0IGVuY29kaW5n
			\s*IGFzIDxkYXRhLz4=
			\s*</data>
			"""
		And the output should match:
			"""
			<key>OnDemandEnabled</key>
			\s*<integer>1</integer>
			"""

	Scenario: The p12pass flag is set.
		When I run `ovpnmcgen.rb g --host aruba.cucumber.org --cafile ca.crt --p12file p12file.p12 --p12pass p12passphrase cucumber aruba`
		Then the output should match:
			"""
			<key>Password</key>
			\s*<string>p12passphrase</string>
			"""

	Scenario: The tafile flag is set.
		Given a file named "ta.key" with:
			"""
			Contents of TLS-Auth Key file
			With newlines
			And more newlines
			That should appear as one line
			"""
		When I run `ovpnmcgen.rb g --host aruba.cucumber.org --cafile ca.crt --p12file p12file.p12 --tafile ta.key cucumber aruba`
		Then the output should match:
			"""
			<key>tls-auth</key>
			\s*<string>Contents of TLS-Auth Key file\\nWith newlines\\nAnd more newlines\\nThat should appear as one line</string>
			"""

	Scenario: The proto and port flags are set.
		When I run `ovpnmcgen.rb g --host aruba.cucumber.org --cafile ca.crt --p12file p12file.p12 --proto tcp --port 1234 cucumber aruba`
		Then the output should match:
			"""
			<key>remote</key>
			\s*<string>aruba.cucumber.org 1234 tcp</string>
			"""

	Scenario: The no-vod flag is set.
		When I run `ovpnmcgen.rb g --host aruba.cucumber.org --cafile ca.crt --p12file p12file.p12 --no-vod cucumber aruba`
		Then the output should match:
			"""
			<key>OnDemandEnabled</key>
			\s*<integer>0</integer>
			"""

	Scenario: The url-probe flag is set.
		When I run `ovpnmcgen.rb g --host aruba.cucumber.org --cafile ca.crt --p12file p12file.p12 --url-probe 'https://url.to.probe/' cucumber aruba`
		Then the output should match:
			"""
			<key>URLStringProbe</key>
			\s*<string>https://url.to.probe/</string>
			"""
		And the output should match:
			"""
			<dict>
			\s*<key>Action</key>
			\s*<string>Ignore</string>
			\s*</dict>
			"""

	Scenario: The url-probe flag is not set.
		When I run `ovpnmcgen.rb g --host aruba.cucumber.org --cafile ca.crt --p12file p12file.p12 cucumber aruba`
		Then the output should not contain:
			"""
			<key>URLStringProbe</key>
			"""
		And the output should not match:
			"""
			<dict>
			\s*<key>Action</key>
			\s*<string>Ignore</string>
			\s*</dict>
			"""

	Scenario: The [un]trusted-ssids flags are set.
		When I run `ovpnmcgen.rb g --host aruba.cucumber.org --cafile ca.crt --p12file p12file.p12 --trusted-ssids trusted1,trusted2 --untrusted-ssids evil3,evil4 cucumber aruba`
		Then the output should match:
			"""
			<string>Disconnect</string>
			\s*<key>SSIDMatch</key>
			\s*<array>
			\s*<string>trusted1</string>
			\s*<string>trusted2</string>
			\s*</array>
			"""
		And the output should match:
			"""
			<string>Connect</string>
			\s*<key>SSIDMatch</key>
			\s*<array>
			\s*<string>evil3</string>
			\s*<string>evil4</string>
			\s*</array>
			"""

	Scenario: The security-level flag is set to paranoid.
		When I run `ovpnmcgen.rb g --host aruba.cucumber.org --cafile ca.crt --p12file p12file.p12 --security-level paranoid cucumber aruba`
		Then the output should match:
			"""
			<key>Action</key>
			\s*<string>Connect</string>
			\s*<key>InterfaceTypeMatch</key>
			\s*<string>Cellular</string>
			"""

	Scenario: The security-level flag is set to high.
		When I run `ovpnmcgen.rb g --host aruba.cucumber.org --cafile ca.crt --p12file p12file.p12 --security-level high cucumber aruba`
		Then the output should match:
			"""
			<key>Action</key>
			\s*<string>Connect</string>
			\s*<key>InterfaceTypeMatch</key>
			\s*<string>WiFi</string>
			"""
		And the output should match:
			"""
			<key>Action</key>
			\s*<string>Ignore</string>
			\s*<key>InterfaceTypeMatch</key>
			\s*<string>Cellular</string>
			"""

	Scenario: The security-level flag is set to medium.
		When I run `ovpnmcgen.rb g --host aruba.cucumber.org --cafile ca.crt --p12file p12file.p12 --security-level medium cucumber aruba`
		Then the output should match:
			"""
			<key>Action</key>
			\s*<string>Ignore</string>
			\s*<key>InterfaceTypeMatch</key>
			\s*<string>WiFi</string>
			"""
		And the output should match:
			"""
			<key>Action</key>
			\s*<string>Disconnect</string>
			\s*<key>InterfaceTypeMatch</key>
			\s*<string>Cellular</string>
			"""

	Scenario: The output file flag is set.
		When I run `ovpnmcgen.rb g --host aruba.cucumber.org --cafile ca.crt --p12file p12file.p12 --output fileout.mobileconfig cucumber aruba`
		Then the stdout should not contain anything
		And the file "fileout.mobileconfig" should contain:
			"""
			<?xml version="1.0" encoding="UTF-8"?>
			<!DOCTYPE plist PUBLIC "-//Apple Computer//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
			<plist version="1.0">
			"""