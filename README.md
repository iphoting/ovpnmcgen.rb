# Ovpnmcgen.rb

OpenVPN iOS Configuration Profile Utility

Generates iOS configuration profiles (.mobileconfig) that configures OpenVPN for use with VPN-on-Demand that are not accessible through the Apple Configurator or the iPhone Configuration Utility.

Although there are many possible VPN-on-Demand (VoD) triggers, this utility currently only implements `SSIDMatch` and `InterfaceTypeMatch`. The following algorithm is executed upon network changes, in order: 

- If wireless SSID matches any specified with `--trusted-ssids`, tear down the VPN connection and do not reconnect on demand.
- Else if wireless SSID matches any specified with `--untrusted-ssids`, unconditionally bring up the VPN connection on the next network attempt.
- Else if the primary network interface becomes Wifi (any SSID except those above), bring up the VPN connection.
- Else if the primary network interface becomes Cellular, leave any existing VPN connection up, but do not reconnect on demand.
- Else, unconditionally bring up the VPN connection on the next network attempt.

Note: The other match triggers, such as `DNSDomainMatch`, `DNSServerAddressMatch`, `URLStringProbe`, and per-connection domain inspection (`ActionParameters`), are not implemented. I reckon some kind of DSL will need to be built to support them; pull-requests are welcome.

## Installation

Install the production version from Rubygems.org:

    $ gem install ovpnmcgen.rb

### Local Development

Clone the source:

	$ git clone https://github.com/iphoting/ovpnmcgen.rb

Build and install the gem:

	$ cd ovpnmcgen.rb/
	$ bundle install   # install dependencies
	# Hack away...
	$ rake install     # build and install gem

## Usage

```
Usage: ovpnmcgen.rb generate [options] <user> <device>

  Options:
    --cafile FILE        Path to OpenVPN CA file. (Required)
    --tafile FILE        Path to TLS Key file. (Required)
    --host HOSTNAME      Hostname of OpenVPN server. (Required)
    --p12file FILE       Path to user PKCS#12 file. (Required)
    --p12pass PASSWORD   Password to unlock PKCS#12 file.
    --[no-]vod           Enable or Disable VPN-On-Demand. [Default: Enabled]
    --trusted-ssids SSIDS List of comma-separated trusted SSIDs.
    --untrusted-ssids SSIDS List of comma-separated untrusted SSIDs.
    -o, --output FILE    Output to file. [Default: stdout]
```

## Examples

### Typical Usage
	$ ovpnmcgen.rb gen --trusted-ssids home --host vpn.example.com \
	--cafile path/to/ca.pem --tafile path/to/ta.key \
	--p12file path/to/john-ipad.p12 --p12pass p12passphrase john ipad

Output:

```
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple Computer//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>PayloadContent</key>
	<array>
		<dict>
			<key>PayloadDescription</key>
			<string>Configures VPN settings, including authentication.</string>
			<key>PayloadDisplayName</key>
			<string>VPN (vpn.example.com/VoD)</string>
			<key>PayloadIdentifier</key>
			<string>com.example.vpn.john-ipad.vpnconfig</string>
			<key>PayloadOrganization</key>
			<string>vpn.example.com</string>
			<key>PayloadType</key>
			<string>com.apple.vpn.managed</string>
			<key>PayloadUUID</key>
			<string>...</string>
			<key>PayloadVersion</key>
			<integer>1</integer>
			<key>UserDefinedName</key>
			<string>vpn.example.com/VoD</string>
			<key>VPN</key>
			<dict>
				<key>AuthenticationMethod</key>
				<string>Certificate</string>
				<key>OnDemandEnabled</key>
				<integer>1</integer>
				<key>OnDemandRules</key>
				<array>
					<dict>
						<key>Action</key>
						<string>Disconnect</string>
						<key>SSIDMatch</key>
						<array>
							<string>home</string>
						</array>
					</dict>
					<dict>
						<key>Action</key>
						<string>Connect</string>
						<key>InterfaceTypeMatch</key>
						<string>WiFi</string>
					</dict>
					<dict>
						<key>Action</key>
						<string>Ignore</string>
						<key>InterfaceTypeMatch</key>
						<string>Cellular</string>
					</dict>
					<dict>
						<key>Action</key>
						<string>Connect</string>
					</dict>
				</array>
				<key>PayloadCertificateUUID</key>
				<string>...</string>
				<key>RemoteAddress</key>
				<string>DEFAULT</string>
			</dict>
			<key>VPNSubType</key>
			<string>net.openvpn.OpenVPN-Connect.vpnplugin</string>
			<key>VPNType</key>
			<string>VPN</string>
			<key>VendorConfig</key>
			<dict>
				<key>ca</key>
				<string>-----BEGIN CERTIFICATE-----\n...\n-----END CERTIFICATE-----</string>
				<key>client</key>
				<string>NOARGS</string>
				<key>comp-lzo</key>
				<string>NOARGS</string>
				<key>dev</key>
				<string>tun</string>
				<key>key-direction</key>
				<string>1</string>
				<key>persist-key</key>
				<string>NOARGS</string>
				<key>persist-tun</key>
				<string>NOARGS</string>
				<key>proto</key>
				<string>udp</string>
				<key>remote</key>
				<string>vpn.example.com 1194 udp</string>
				<key>remote-cert-tls</key>
				<string>server</string>
				<key>resolv-retry</key>
				<string>infinite</string>
				<key>tls-auth</key>
				<string>#\n# 2048 bit OpenVPN static key\n#\n-----BEGIN OpenVPN Static key V1-----\n...\n-----END OpenVPN Static key V1-----</string>
				<key>verb</key>
				<string>3</string>
			</dict>
		</dict>
		<dict>
			<key>Password</key>
			<string>p12passphrase</string>
			<key>PayloadCertificateFileName</key>
			<string>john-ipad.p12</string>
			<key>PayloadContent</key>
			<data>
			base64data
			</data>
			<key>PayloadDescription</key>
			<string>Provides device authentication (certificate or identity).</string>
			<key>PayloadDisplayName</key>
			<string>john-ipad.p12</string>
			<key>PayloadIdentifier</key>
			<string>com.example.vpn.john-ipad.credential</string>
			<key>PayloadOrganization</key>
			<string>vpn.example.com</string>
			<key>PayloadType</key>
			<string>com.apple.security.pkcs12</string>
			<key>PayloadUUID</key>
			<string>...</string>
			<key>PayloadVersion</key>
			<integer>1</integer>
		</dict>
	</array>
	<key>PayloadDescription</key>
	<string>OpenVPN Configuration Payload for john-ipad@vpn.example.com</string>
	<key>PayloadDisplayName</key>
	<string>vpn.example.com OpenVPN iphoting@ipad</string>
	<key>PayloadIdentifier</key>
	<string>com.example.vpn.john-ipad</string>
	<key>PayloadOrganization</key>
	<string>vpn.example.com</string>
	<key>PayloadRemovalDisallowed</key>
	<false/>
	<key>PayloadType</key>
	<string>Configuration</string>
	<key>PayloadUUID</key>
	<string>...</string>
	<key>PayloadVersion</key>
	<integer>1</integer>
</dict>
</plist>
```

### Extended Usage
	$ ovpnmcgen.rb gen --trusted-ssids home,school --untrusted-ssids virusnet \
	--host vpn.example.com --cafile path/to/ca.pem --tafile path/to/ta.key \
	--p12file path/to/john-ipad.p12 --p12pass p12passphrase john ipad

Output similar to above:
```
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple Computer//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>PayloadContent</key>
	<array>
		<dict>
			...
			<key>VPN</key>
			<dict>
				...
				<key>OnDemandRules</key>
				<array>
					<dict>
						<key>Action</key>
						<string>Disconnect</string>
						<key>SSIDMatch</key>
						<array>
							<string>home</string>
							<string>school</string>
						</array>
					</dict>
					<dict>
						<key>Action</key>
						<string>Connect</string>
						<key>SSIDMatch</key>
						<array>
							<string>virusnet</string>
						</array>
					</dict>
					<dict>
						<key>Action</key>
						<string>Connect</string>
						<key>InterfaceTypeMatch</key>
						<string>WiFi</string>
					</dict>
					<dict>
						<key>Action</key>
						<string>Ignore</string>
						<key>InterfaceTypeMatch</key>
						<string>Cellular</string>
					</dict>
					<dict>
						<key>Action</key>
						<string>Connect</string>
					</dict>
				</array>
				...
			</dict>
			...
		</dict>
		...
	</array>
	...
</dict>
</plist>
```

### Using OpenSSL to convert files into PKCS#12 (.p12)
	openssl pkcs12 -export -out path/to/john-ipad.p12 \
	-inkey path/to/john-ipad.key -in path/to/john-ipad.crt \
	-passout pass:p12passphrase -name john-ipad@vpn.example.com

## TODO

- Config file to specify global options, such as `--cafile`, `--tafile`, `--host`, `--[un]trusted-ssids`.
- Batch-operation mode, with CSV-file as input, and a CSV UUID-index file to track generated profiles as output.

	The same UUID should be used for profile updates, so that iOS knows which profile to replace, especially in MDM environments.

- Adopt OpenVPN parameters from an OpenVPN-compatible client.conf input file.
- Sign/Encrypt .mobileconfig.

	Current workaround is to use a trusted MDM solution to securely push these unsigned, unencrypted profiles to iOS devices, through the encrypted MDM connected.

## References

- Apple, at <https://developer.apple.com/library/ios/featuredarticles/iPhoneConfigurationProfileRef/Introduction/Introduction.html#//apple_ref/doc/uid/TP40010206-CH1-SW27>.

## Contributing

1. Fork it (<http://github.com/iphoting/ovpnmcgen.rb/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
