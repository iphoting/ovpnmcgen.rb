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
		And a file named "cert.crt" with:
			"""
			Contents of cert file
			With newlines
			And more newlines
			That should appear as one line
			"""
		And a file named "key.pem" with:
			"""
			Contents of key file
			With newlines
			And more newlines
			That should appear as one line
			"""

	Scenario: I need help
		When I run `ovpnmcgen.rb help g`
		Then the output should contain "Usage"

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

	@v0.6.0
	Scenario: Correct arguments with all required flags, host, cafile, except (either p12file or (cert and key)).
		When I run `ovpnmcgen.rb g --host aruba.cucumber.org --cafile ca.crt cucumber aruba`
		And the output should not contain "error: Host"
		And the output should not contain "error: cafile"
		Then the output should contain "error: PKCS#12 or cert & key"

	Scenario: Correct arguments with all required flags, host, cafile, and p12file (no cert and key).
		When I run `ovpnmcgen.rb g --host aruba.cucumber.org --cafile ca.crt --p12file p12file.p12 cucumber aruba`
		And the output should not contain "error: Host"
		And the output should not contain "error: cafile"
		And the output should not contain "error: PKCS#12"
		Then the output should match:
			"""
			<\?xml version="1.0" encoding="UTF-8"\?>
			<!DOCTYPE plist PUBLIC "-\/\/Apple*\/\/DTD PLIST 1.0\/\/EN" "http:\/\/www.apple.com\/DTDs\/PropertyList-1.0.dtd">
			<plist version="1.0">
			"""
		And the output should match:
			"""
			<key>AuthenticationMethod</key>
			\s*<string>Certificate</string>
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

	@OCv1.2 @v0.6.0
	Scenario: Correct arguments with all required flags, host, cafile, cert, and key (no p12file).
		When I run `ovpnmcgen.rb g --host aruba.cucumber.org --cafile ca.crt --cert cert.crt --key key.pem cucumber aruba`
		And the output should not contain "error: Host"
		And the output should not contain "error: cafile"
		And the output should not contain "error: PKCS#12 or cert & key"
		Then the output should match:
			"""
			<\?xml version="1.0" encoding="UTF-8"\?>
			<!DOCTYPE plist PUBLIC "-\/\/Apple*\/\/DTD PLIST 1.0\/\/EN" "http:\/\/www.apple.com\/DTDs\/PropertyList-1.0.dtd">
			<plist version="1.0">
			"""
		And the output should match:
			"""
			<key>AuthenticationMethod</key>
			\s*<string>Password</string>
			"""
		And the output should match:
			"""
			<key>AuthName</key>
			\s*<string>cucumber-aruba</string>
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
			<key>cert</key>
			\s*<string>Contents of cert file\\nWith newlines\\nAnd more newlines\\nThat should appear as one line</string>
			"""
		And the output should match:
			"""
			<key>key</key>
			\s*<string>Contents of key file\\nWith newlines\\nAnd more newlines\\nThat should appear as one line</string>
			"""
		And the output should match:
			"""
			<key>OnDemandEnabled</key>
			\s*<integer>1</integer>
			"""
		And the output should not match:
			"""
			<key>PayloadCertificateUUID</key>
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

	Scenario: The tlscrypt flag is set.
		Given a file named "tlscrypt.key" with:
			"""
			Contents of TLS-Crypt Key file
			With newlines
			And more newlines
			That should appear as one line
			"""
		When I run `ovpnmcgen.rb g --host aruba.cucumber.org --cafile ca.crt --p12file p12file.p12 --tlscryptfile tlscrypt.key cucumber aruba`
		Then the output should match:
			"""
			<key>tls-crypt</key>
			\s*<string>Contents of TLS-Crypt Key file\\nWith newlines\\nAnd more newlines\\nThat should appear as one line</string>
			"""

	Scenario: Both tafile and tlscryptfile flags are set.
		When I run `ovpnmcgen.rb g --host aruba.cucumber.org --cafile ca.crt --p12file p12file.p12 --tafile ta.key --tlscryptfile tlscrypt.key cucumber aruba`
		Then the output should contain "error: tafile and tlscryptfile cannot be both set"

	Scenario: The proto and port flags are set.
		When I run `ovpnmcgen.rb g --host aruba.cucumber.org --cafile ca.crt --p12file p12file.p12 --proto tcp --port 1234 cucumber aruba`
		Then the output should match:
			"""
			<key>remote</key>
			\s*<string>aruba.cucumber.org 1234 tcp</string>
			"""

	@OCv1.2 @v0.6.0
	Scenario: The no-vod flag is set.
		When I run `ovpnmcgen.rb g --host aruba.cucumber.org --cafile ca.crt --p12file p12file.p12 --no-vod cucumber aruba`
		Then the output should match:
			"""
			<key>OnDemandEnabled</key>
			\s*<integer>0</integer>
			"""
		And the output should match:
			"""
			<key>vpn-on-demand</key>
			\s*<string>0</string>
			"""

	Scenario: The no-vod flag is not set.
		When I run `ovpnmcgen.rb g --host aruba.cucumber.org --cafile ca.crt --p12file p12file.p12 cucumber aruba`
		Then the output should match:
			"""
			<key>OnDemandEnabled</key>
			\s*<integer>1</integer>
			"""
		And the output should not match:
			"""
			<key>vpn-on-demand</key>
			\s*<string>0</string>
			"""

	@OCv1.2 @v0.6.0
	Scenario: The 1.2 flag is set.
		When I run `ovpnmcgen.rb g --host aruba.cucumber.org --cafile ca.crt --p12file p12file.p12 --v12compat cucumber aruba`
		Then the output should match:
			"""
			<key>VPNSubType</key>
			\s*<string>net.openvpn.connect.app</string>
			"""

	@OCv1.2 @v0.6.0
	Scenario: The 1.2 flag is not set.
		When I run `ovpnmcgen.rb g --host aruba.cucumber.org --cafile ca.crt --p12file p12file.p12 cucumber aruba`
		Then the output should match:
			"""
			<key>VPNSubType</key>
			\s*<string>net.openvpn.OpenVPN-Connect.vpnplugin</string>
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

	Scenario: The [un]trusted-ssids flags are set.
		When I run `ovpnmcgen.rb g --host aruba.cucumber.org --cafile ca.crt --p12file p12file.p12 --trusted-ssids trusted1,trusted2 --untrusted-ssids evil3,evil4 cucumber aruba`
		Then the output should match:
			"""
			<string>Disconnect</string>
			\s*<key>InterfaceTypeMatch</key>
			\s*<string>WiFi</string>
			\s*<key>SSIDMatch</key>
			\s*<array>
			\s*<string>trusted1</string>
			\s*<string>trusted2</string>
			\s*</array>
			"""
		And the output should match:
			"""
			<string>Connect</string>
			\s*<key>InterfaceTypeMatch</key>
			\s*<string>WiFi</string>
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
			"""
		And the file "fileout.mobileconfig" should contain:
			"""
			<plist version="1.0">
			"""

	Scenario: The remotes flag is set with multiple hosts.
		When I run `ovpnmcgen.rb g --host aruba.cucumber.org --cafile ca.crt --p12file p12file.p12 --remotes "1.example.org 1195 tcp","2.example.org 1196 tcp" cucumber aruba`
		Then the output should match:
			"""
			<key>remote.1</key>
			\s*<string>aruba.cucumber.org 1194 udp</string>
			"""
		And the output should match:
			"""
			<key>remote.2</key>
			\s*<string>1.example.org 1195 tcp</string>
			\s*<key>remote.3</key>
			\s*<string>2.example.org 1196 tcp</string>
			"""
		And the output should not contain "<key>remote</key>"

	Scenario: The domains flag is not set.
		When I run `ovpnmcgen.rb g --host aruba.cucumber.org --cafile ca.crt --p12file p12file.p12 cucumber aruba`
		Then the output should not match:
			"""
			<key>Action</key>
			\s*<string>EvaluateConnection</string>
			"""
		And the output should not match:
			"""
			<key>ActionParameters</key>
			\s*<array>
			\s*<dict>
			\s*<key>DomainAction</key>
			\s*<string>ConnectIfNeeded</string>
			\s*<key>Domains</key>
			\s*</dict>
			\s*</array>
			"""

	Scenario: The domains flag is set with one domain.
		When I run `ovpnmcgen.rb g --host aruba.cucumber.org --cafile ca.crt --p12file p12file.p12 --domains "example.com" cucumber aruba`
		Then the output should match:
			"""
			<key>Action</key>
			\s*<string>EvaluateConnection</string>
			"""
		And the output should match:
			"""
			<key>ActionParameters</key>
			\s*<array>
			\s*<dict>
			\s*<key>DomainAction</key>
			\s*<string>ConnectIfNeeded</string>
			\s*<key>Domains</key>
			\s*<array>
			\s*<string>example\.com</string>
			\s*</array>
			\s*</dict>
			\s*</array>
			"""

	Scenario: The domains flag is set with multiple domains.
		When I run `ovpnmcgen.rb g --host aruba.cucumber.org --cafile ca.crt --p12file p12file.p12 --domains "*.example.com,example.com" cucumber aruba`
		Then the output should match:
			"""
			<key>Action</key>
			\s*<string>EvaluateConnection</string>
			"""
		And the output should match:
			"""
			<key>ActionParameters</key>
			\s*<array>
			\s*<dict>
			\s*<key>DomainAction</key>
			\s*<string>ConnectIfNeeded</string>
			\s*<key>Domains</key>
			\s*<array>
			\s*<string>\*\.example\.com</string>
			\s*<string>example\.com</string>
			\s*</array>
			\s*</dict>
			\s*</array>
			"""

	Scenario: The domains flag is set with multiple domains and domain probe URL is set.
		When I run `ovpnmcgen.rb g --host aruba.cucumber.org --cafile ca.crt --p12file p12file.p12 --domains "*.example.com,example.com" --domain-probe-URL "https://example.com/404.html" cucumber aruba`
		Then the output should match:
			"""
			<key>Action</key>
			\s*<string>EvaluateConnection</string>
			"""
		And the output should match:
			"""
			<key>ActionParameters</key>
			\s*<array>
			\s*<dict>
			\s*<key>DomainAction</key>
			\s*<string>ConnectIfNeeded</string>
			\s*<key>Domains</key>
			\s*<array>
			\s*<string>\*\.example\.com</string>
			\s*<string>example\.com</string>
			\s*</array>
			\s*<key>RequiredURLStringProbe</key>
			\s*<string>https:\/\/example\.com\/404\.html</string>
			\s*</dict>
			\s*</array>
			"""

	Scenario: The profile UUID flag is set.
		When I run `ovpnmcgen.rb g --host aruba.cucumber.org --cafile ca.crt --p12file p12file.p12 --profile-uuid A43E7B13-4F02-4121-9B70-81C734E495C1 cucumber aruba`
		Then the output should match:
			"""
			<key>PayloadIdentifier</key>
			\s*<string>com.apple.vpn.managed.A43E7B13-4F02-4121-9B70-81C734E495C1</string>
			"""

	Scenario: The VPN profile name flag is set.
		When I run `ovpnmcgen.rb g --host aruba.cucumber.org --cafile ca.crt --p12file p12file.p12 --vpn-name foobar cucumber aruba`
		Then the output should match:
			"""
			<key>UserDefinedName</key>
			\s*<string>foobar</string>
			"""

	Scenario: The idle timer flag is set.
		When I run `ovpnmcgen.rb g --host aruba.cucumber.org --cafile ca.crt --p12file p12file.p12 --idle-timer 10 cucumber aruba`
		Then the output should match:
			"""
			<key>DisconnectOnIdle</key>
			\s*<integer>1</integer>
			\s*<key>DisconnectOnIdleTimer</key>
			\s*<integer>10</integer>
			"""
