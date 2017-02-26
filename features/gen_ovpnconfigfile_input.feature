Feature: Generate Functionality From Supplied OpenVPN Config File
	In order to generate a properly formatted plist mobileconfig from supplied openvpn configfile
	As a CLI
	The specified openvpn file needs to be parsed properly

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
		And a file named "clean.ovpn" with:
			"""
			##############################################
			# Sample client-side OpenVPN 2.0 config file #
			# for connecting to multi-client server.     #
			#                                            #
			# This configuration can be used by multiple #
			# clients, however each client should have   #
			# its own cert and key files.                #
			#                                            #
			# On Windows, you might want to rename this  #
			# file so it has a .ovpn extension           #
			##############################################

			# Specify that we are a client and that we
			# will be pulling certain config file directives
			# from the server.
			client

			# Use the same setting as you are using on
			# the server.
			# On most systems, the VPN will not function
			# unless you partially or fully disable
			# the firewall for the TUN/TAP interface.
			;dev tap
			dev tun

			# Windows needs the TAP-Win32 adapter name
			# from the Network Connections panel
			# if you have more than one.  On XP SP2,
			# you may need to disable the firewall
			# for the TAP adapter.
			;dev-node MyTap

			# Are we connecting to a TCP or
			# UDP server?  Use the same setting as
			# on the server.
			;proto tcp
			proto udp

			# The hostname/IP and port of the server.
			# You can have multiple remote entries
			# to load balance between the servers.
			remote should.not.appear 1194
			;remote my-server-2 1194

			# Choose a random host from the remote
			# list for load-balancing.  Otherwise
			# try hosts in the order specified.
			;remote-random

			# Keep trying indefinitely to resolve the
			# host name of the OpenVPN server.  Very useful
			# on machines which are not permanently connected
			# to the internet such as laptops.
			resolv-retry infinite

			# Most clients don't need to bind to
			# a specific local port number.
			nobind

			# Downgrade privileges after initialization (non-Windows only)
			user nobody
			group nobody

			# Try to preserve some state across restarts.
			persist-key
			persist-tun

			# If you are connecting through an
			# HTTP proxy to reach the actual OpenVPN
			# server, put the proxy server/IP and
			# port number here.  See the man page
			# if your proxy server requires
			# authentication.
			;http-proxy-retry # retry on connection failures
			;http-proxy [proxy server] [proxy port #]

			# Wireless networks often produce a lot
			# of duplicate packets.  Set this flag
			# to silence duplicate packet warnings.
			;mute-replay-warnings

			# SSL/TLS parms.
			# See the server config file for more
			# description.  It's best to use
			# a separate .crt/.key file pair
			# for each client.  A single ca
			# file can be used for all clients.
			;ca ca.crt
			;cert client.crt
			;key client.key
			pkcs12 client.p12

			# Verify server certificate by checking
			# that the certicate has the nsCertType
			# field set to "server".  This is an
			# important precaution to protect against
			# a potential attack discussed here:
			#  http://openvpn.net/howto.html#mitm
			#
			# To use this feature, you will need to generate
			# your server certificates with the nsCertType
			# field set to "server".  The build-key-server
			# script in the easy-rsa folder will do this.
			#ns-cert-type server

			remote-cert-tls server

			# If a tls-auth key is used on the server
			# then every client must also have the key.
			tls-auth ta.key 1

			# Select a cryptographic cipher.
			# If the cipher option is used on the server
			# then you must also specify it here.
			;cipher x

			# Enable compression on the VPN link.
			# Don't enable this unless it is also
			# enabled in the server config file.
			comp-lzo

			# Set log file verbosity.
			verb 3

			# Silence repeating messages
			;mute 20
			"""

	Scenario: A decent openvpn config file is specified.
		When I run `ovpnmcgen.rb g --host aruba.cucumber.org --cafile ca.crt --p12file p12file.p12 --ovpnconfigfile clean.ovpn cucumber aruba`
		Then the output should match:
			"""
			<\?xml version="1.0" encoding="UTF-8"\?>
			<!DOCTYPE plist PUBLIC "-\/\/Apple*\/\/DTD PLIST 1.0\/\/EN" "http:\/\/www.apple.com\/DTDs\/PropertyList-1.0.dtd">
			<plist version="1.0">
			"""
		And the output should contain "aruba.cucumber.org 1194 udp"
		And the output should not contain "should.not.appear 1194"
		And the output should not contain "persist-key"
		And the output should not contain "persist-tun"
		And the output should not contain "<key>pkcs12</key>"
		And the output should not contain "<key>cert</key>"
		And the output should not contain "<key>key</key>"
		And the output should not contain "<key>resolv-retry</key>"
		And the output should match:
			"""
			<key>comp-lzo</key>
			\s*<string>NOARGS</string>
			"""
