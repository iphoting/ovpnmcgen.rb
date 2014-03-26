# Ovpnmcgen.rb

OpenVPN iOS Configuration Profile Utility

This utility generates configuration profiles that enables VPN-on-Demand, as documented by Apple in <https://developer.apple.com/library/ios/featuredarticles/iPhoneConfigurationProfileRef/Introduction/Introduction.html#//apple_ref/doc/uid/TP40010206-CH1-SW27>.

## Installation

Install it yourself as:

    $ gem install ovpnmcgen.rb

## Usage

	$ ovpnmcgen.rb gen --trusted-ssids home,school --untrusted-ssids virusnet --host vpn.example.com --cafile path/to/ca.pem --tafile path/to/ta.key john ipad path/to/john-ipad.p12 p12passphrase

## Contributing

1. Fork it (<http://github.com/iphoting/ovpnmcgen.rb/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
