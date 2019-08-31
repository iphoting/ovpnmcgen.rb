# Ovpnmcgen.rb

OpenVPN iOS Configuration Profile Utility

[![GitHub version](https://badge.fury.io/gh/iphoting%2Fovpnmcgen.rb.svg)](http://badge.fury.io/gh/iphoting%2Fovpnmcgen.rb)
[![Gem Version](https://badge.fury.io/rb/ovpnmcgen.rb.svg)](http://badge.fury.io/rb/ovpnmcgen.rb)
[![Build Status](https://travis-ci.org/iphoting/ovpnmcgen.rb.svg?branch=develop)](https://travis-ci.org/iphoting/ovpnmcgen.rb)

Generates iOS configuration profiles (.mobileconfig) that configures OpenVPN for use with VPN-on-Demand that are not accessible through the Apple Configurator or the iPhone Configuration Utility.

---

**OpenVPN Connect (iOS) v1.2.x**: 
- Breaking changes: enable the `--v12compat` switch.
- Bug/workaround: enable the `--cert` & `--key` switches as necessary.

Refer to [known issues](#known-issues) below for more details.

---

Although there are many possible VPN-on-Demand (VoD) triggers, this utility currently only implements `SSIDMatch`, `InterfaceTypeMatch`, and optionally `URLStringProbe`. For 'high' (default) security level, the following algorithm is executed upon network changes, in order:

- If wireless SSID matches any specified with `--trusted-ssids`, tear down the VPN connection and do not reconnect on demand.
- Else if wireless SSID matches any specified with `--untrusted-ssids`, unconditionally bring up the VPN connection on the next network attempt.
- Else if the primary network interface becomes Wifi (any SSID except those above), unconditionally bring up the VPN connection on the next network attempt.
- Else if the primary network interface becomes Cellular, leave any existing VPN connection up, but do not reconnect on demand.
- Else, leave any existing VPN connection up, but do not reconnect on demand.

Note: The other match triggers, such as `DNSDomainMatch`, `DNSServerAddressMatch`, and per-connection domain inspection (`ActionParameters`), are not implemented. I reckon some kind of DSL will need to be built to support them; pull-requests are welcome.

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
    -c, --config FILE    Specify path to config file. [Default: .ovpnmcgen.rb.yml]
    --cafile FILE        Path to OpenVPN CA file. (Required)
    --tafile FILE        Path to TLS-Auth Key file.
    --tlscryptfile FILE	 Path to TLS-Crypt Key file.
    --cert FILE          Path to Cert file.
    --key FILE           Path to Private Key file.
    --host HOSTNAME      Hostname of OpenVPN server. (Required)
    --proto PROTO        OpenVPN server protocol. [Default: udp]
    -p, --port PORT      OpenVPN server port. [Default: 1194]
    --p12file FILE       Path to user PKCS#12 file.
    --p12pass PASSWORD   Password to unlock PKCS#12 file.
    --[no-]vod           Enable or Disable VPN-On-Demand. 
                         When Disabled, sets `vpn-on-demand: 0`, so that OpenVPN Connect can control this profile. [Default: Enabled]
    --v12compat          Enable OpenVPN Connect 1.2.x compatibility. 
                         When Enabled, use updated `VPNSubType: net.openvpn.connect.app` 
                         (changed since OpenVPN Connect 1.2.x). [Default: Disabled]
    --security-level LEVEL Security level of VPN-On-Demand Behaviour: paranoid, high, medium. [Default: high]
    --vpn-uuid UUID      Override a VPN configuration payload UUID.
    --vpn-name NAME	     Override a VPN configuration payload name displayed under
                         Settings.app > General > VPN.
    --profile-uuid UUID  Override a Profile UUID.
    --cert-uuid UUID     Override a Certificate payload UUID.
    -t, --trusted-ssids SSIDS List of comma-separated trusted SSIDs.
    -u, --untrusted-ssids SSIDS List of comma-separated untrusted SSIDs.
    -d, --domains DOMAINS List of comma-separated domain names requiring VPN service.
    --domain-probe-url PROBE An HTTP(S) URL to probe, using a GET request. If no HTTP response code is received from the server, a VPN connection is established in response.
    --trusted-ssids-probe-url PROBE An HTTP(S) URL to probe, using a GET request. If no HTTP response code is received from the server, a VPN connection is established in response.
    --url-probe URL      This URL must return HTTP status 200, without redirection, before the VPN service will try establishing.
    --remotes REMOTES	 List of comma-separated alternate remotes: "<host> <port> <proto>".
    --idle-timer TIME    Disconnect from VPN when idle for a certain period of time (in seconds) scenarios. Requires disabling "Reconnect On Wakeup" on OpenVPN.app.
    --ovpnconfigfile FILE Path to OpenVPN client config file.
    -o, --output FILE    Output to file. [Default: stdout]
```

### Configuration

Option flags can be set using environment variables or placed into a YAML formatted file. The default filename `.ovpnmcgen.rb.yml` will be searched for in `./`, and then `~/`.

Note: Only for YAML configuration files and environment variables, flags with hyphens (-) are replaced with underscores (_), i.e. `--trusted-ssids safe` should be `trusted_ssids: safe`.

Sample:

```
untrusted_ssids: [dangerous1, dangerous2]
trusted_ssids: [trust]
host: vpn.example.com
cafile: /etc/openvpn/ca.crt
tafile: /etc/openvpn/ta.key
url_probe: https://vpn.example.com/canVPN.php
```

### Security Levels

There are three different security levels to choose from, 'paranoid', 'high' (default), and 'medium'. The algorithm illustrated above is for 'high'.

For 'paranoid' security level, the following algorithm is executed upon network changes, in order:

- If wireless SSID matches any specified with `--trusted-ssids`, tear down the VPN connection and do not reconnect on demand.
- Else if wireless SSID matches any specified with `--untrusted-ssids`, unconditionally bring up the VPN connection on the next network attempt.
- Else if the primary network interface becomes Wifi (any SSID except those above), unconditionally bring up the VPN connection on the next network attempt.
- Else if the primary network interface becomes Cellular, unconditionally bring up the VPN connection on the next network attempt.
- Else, leave any existing VPN connection up, but do not reconnect on demand.

For 'medium' security level, the following algorithm is executed upon network changes, in order:

- If wireless SSID matches any specified with `--trusted-ssids`, tear down the VPN connection and do not reconnect on demand.
- Else if wireless SSID matches any specified with `--untrusted-ssids`, unconditionally bring up the VPN connection on the next network attempt.
- Else if the primary network interface becomes Wifi (any SSID except those above), leave any existing VPN connection up, but do not reconnect on demand.
- Else if the primary network interface becomes Cellular, leave any existing VPN connection up, but do not reconnect on demand.
- Else, leave any existing VPN connection up, but do not reconnect on demand.

### URL Probe

Apple provides a `URLStringProbe` test condition where a VPN connection will only be established, if and only if a specified URL is successfully fetched (returning a 200 HTTP status code) without redirection.

This feature can be enabled for statistical and maintenance-protection reasons. Otherwise, it can also workaround a circular limitation with unsecured wireless captive portals. See Known Issues below for further elaboration.

By enabling this option, you will need to reliably and quickly respond with HTTP status code 200 at the URL string supplied.

### Domain Matching
To require an iOS device to bring up the VPN when `example.com` is requested is not so easy, especially if it is has a publicly accessible DNS resolution. 

Apple provides an `EvaluateConnection` and `ActionParameters` configuration options with the view that certain domains will have DNS resolution failures, and hence, require the VPN to be up. In most corporate cases with internal-facing hostnames, it works well. See the `--domains` option.

However, if there are certain sensitive public sites (or blocked sites) that you decide that a VPN should be brought up instead, you will need to additionally specify a `RequiredURLStringProbe` that returns a non-200 response. See the `--domain-probe-url` option.

## Examples

### Typical Usage
	$ ovpnmcgen.rb gen --v12compat \
	--trusted-ssids home \
	--host vpn.example.com \
	--cafile path/to/ca.pem \
	--tafile path/to/ta.key \
	--url-probe http://vpn.example.com/status \
	--p12file path/to/john-ipad.p12 \
	--p12pass p12passphrase \
	john ipad

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
						<key>URLStringProbe</key>
						<string>http://vpn.example.com/status</string>
					</dict>
					<dict>
						<key>Action</key>
						<string>Connect</string>
						<key>InterfaceTypeMatch</key>
						<string>WiFi</string>
						<key>URLStringProbe</key>
						<string>http://vpn.example.com/status</string>
					</dict>
					<dict>
						<key>Action</key>
						<string>Ignore</string>
						<key>InterfaceTypeMatch</key>
						<string>Cellular</string>
						<key>URLStringProbe</key>
						<string>http://vpn.example.com/status</string>
					</dict>
					<dict>
						<key>Action</key>
						<string>Connect</string>
						<key>URLStringProbe</key>
						<string>http://vpn.example.com/status</string>
					</dict>
				</array>
				<key>PayloadCertificateUUID</key>
				<string>...</string>
				<key>RemoteAddress</key>
				<string>DEFAULT</string>
			</dict>
			<key>VPNSubType</key>
			<string>net.openvpn.connect.app</string>
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
	$ ovpnmcgen.rb gen --v12compat \
	--trusted-ssids home,school \
	--untrusted-ssids virusnet \
	--host vpn.example.com \
	--cafile path/to/ca.pem \
	--tafile path/to/ta.key \
	--url-probe http://vpn.example.com/status \
	--p12file path/to/john-ipad.p12 \
	--p12pass p12passphrase \
	john ipad

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
						<key>URLStringProbe</key>
						<string>http://vpn.example.com/status</string>
					</dict>
					<dict>
						<key>Action</key>
						<string>Connect</string>
						<key>InterfaceTypeMatch</key>
						<string>WiFi</string>
						<key>URLStringProbe</key>
						<string>http://vpn.example.com/status</string>
					</dict>
					<dict>
						<key>Action</key>
						<string>Ignore</string>
						<key>InterfaceTypeMatch</key>
						<string>Cellular</string>
						<key>URLStringProbe</key>
						<string>http://vpn.example.com/status</string>
					</dict>
					<dict>
						<key>Action</key>
						<string>Connect</string>
						<key>URLStringProbe</key>
						<string>http://vpn.example.com/status</string>
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

### Using OpenSSL to convert from PKCS#12 (.p12) to Cert PEM file
	openssl pkcs12 -in path/to/john-ipad.p12 -out path/to/john-ipad-cert.crt \
	-nodes -nokeys

### Using OpenSSL to convert from PKCS#12 (.p12) to Key PEM file
	openssl pkcs12 -in path/to/john-ipad.p12 -out path/to/john-ipad-key.pem \
	-nodes -nocerts

## Known Issues

- OpenVPN Connect v1.2.5 breaking changes

	*Diagnosis*: Certificates no longer found or VoD mobileconfig broken after OpenVPN Connect upgrade to v1.2.5.

	The VPN switch in the Settings.app jumps rapidly from On to Off, status switches from Connecting... to Disconnected immediately. No logs produced within the OpernVPN Connect app log viewer.

	This is caused by 1) a breaking change, where the `VPNSubType` has changed, and 2) a bug where the OpenVPN Connect is missing a keychain access entitlement from Apple.

	*Solution + Workaround*: Enable the `--v12compat` switch to resolve (1), and use `--cert` and `--key` switches to workaround (2).

- "Not connected to Internet" error/behaviour when VPN should be established.

	*Diagnosis*: Load any site in Safari. An error message "Safari cannot open the page because your iPhone is not connected to the Internet" will be presented.

	There is a bug in the iOS/OS X network routing code that hangs the routing system, preventing the gateway or IP address from being set. This happens more frequently when the tunnel is brought up/down more frequently.

	*Solution*: Upgrade to iOS 8.1. The new iOS update seems to have mostly solved issues surrounding the networking stack.

	*Workaround*: Hard-restart iOS. Press and hold down both the home and sleep/wake buttons until iOS turns off and back on with the Apple boot up screen. Release when the Apple boot up screen appears.

- Weird Rapid Connecting…/Disconnected behaviour.

	*Diagnosis*: VPN status in Settings.app rapid alternates between Connecting… and Disconnected.

	Usually happens when the VoD component is stuck in an infinite loop. Not sure what triggers it.

	*Solution*: Upgrade to iOS 8.1. The new iOS update seems to have mostly solved issues surrounding the networking stack.

	*Workaround*: Hard-restart iOS. Press and hold down both the home and sleep/wake buttons until iOS turns off and back on with the Apple boot up screen. Release when the Apple boot up screen appears.

- Cannot load Captive Portals (Hotspots on unsecured Wireless networks).

	Some unsecured hotspots require navigating certain webpages before full access to the internet is available. This requirement blocks VPN connections and iOS will also block captive portal access, waiting on the VPN connection. This circular dependency results in no internet access.

	*Solution*: Implement `URLStringProbe` where, if and only if this URL is successfully fetched (returning a 200 HTTP status code) without redirection, will the VPN service be required, relied on, and brought up. Enable with the `--url-probe` flag.

	*Workaround*: Manually disable VPN-on-Demand in Settings.app > VPN > Server (i) option screen. Reenable only after Internet access is available.

## TODO

- Config file to specify global options, such as `--cafile`, `--tafile`, `--host`, `--[un]trusted-ssids`.

	See commit `#d9c015618` for feature.

- Batch-operation mode, with CSV-file as input, and a CSV UUID-index file to track generated profiles as output.

	The same UUID should be used for profile updates, so that iOS knows which profile to replace, especially in MDM environments.

	Custom UUID overrides now supported via `--{profile,vpn,cert}-uuid`.

- Adopt OpenVPN parameters from an OpenVPN-compatible client.conf input file.

	Implemented, but does not support inline `<ca|tls-auth>` data enclosures, and command line flags (that are required) override config file values.

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
