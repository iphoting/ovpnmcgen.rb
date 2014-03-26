# Ovpnmcgen.rb

OpenVPN iOS Configuration Profile Utility

This utility generates configuration profiles that enables VPN-on-Demand, as documented by Apple in <https://developer.apple.com/library/ios/featuredarticles/iPhoneConfigurationProfileRef/Introduction/Introduction.html#//apple_ref/doc/uid/TP40010206-CH1-SW27>.

## Installation

Install it yourself as:

    $ gem install ovpnmcgen.rb

## Usage

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

### Using OpenSSL to generate a PKCS#12 file
	openssl pkcs12 -export -out path/to/john-ipad.p12 \
	-inkey path/to/john-ipad.key -in path/to/john-ipad.crt \
	-passout pass:p12passphrase

## Contributing

1. Fork it (<http://github.com/iphoting/ovpnmcgen.rb/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
