# ChangeLog

<a name="unreleased"></a>
## [Unreleased]



<a name="v0.7.1"></a>
## [v0.7.1] - 2019-09-09

- Bug fix: Do not disconnect from VPN over cellular if security level is medium ([#33](https://github.com/iphoting/ovpnmcgen.rb/issues/33))


<a name="v0.7.0"></a>
## [v0.7.0] - 2019-08-31

- Improve url probe handling
- Extract user and device information from p12
- Add support for disconnect on idle timer
- Add support for customizing the VPN profile name
- Make profile uuid stable
- Improve profile description with VPN config map
- Make vpn uuid stable
- Make cert uuid stable
- Add support for TLS-Crypt
- Add workaround for global config flag not being parsed


<a name="v0.6.0"></a>
## [v0.6.0] - 2018-01-27

- Fixed: Without `--p12file`, `AuthenticationMethod` must be set to `Password`.
- Added support for `--cert` and `--key` for inline attachment of certificate and key, to workaround bug in OpenVPN Connect 1.2.5.
- Added `--v12compat` switch for OpenVPN Connect 1.2.x compatibility for updated bundle identifier (VPNSubType) `net.openvpn.connect.app` (changed since OpenVPN Connect 1.2.x).
- Added support for `vpn-on-demand: 0` key/value pair with `--no-vod` is set, so that OpenVPN Connect can control this profile..
- Fixed: Domain VoD Actions should not be included without `--domains` flag.
- Added support for `EvaluateConnection`, `Domains`, via `--domains`. It will include an `ActionParameters` dict containing `Domains`, and if `--domain-probe-url` is set, also contains `RequiredURLStringProbe`.


<a name="v0.5.0"></a>
## [v0.5.0] - 2015-02-22

- New feature: Specify multiple remotes with `--remotes "host2 1194 tcp","host3 1195 udp"` flag.


<a name="v0.4.2"></a>
## [v0.4.2] - 2014-07-05

- Bugfix: Default catch-all rule should be 'Ignore'.


<a name="v0.4.1"></a>
## [v0.4.1] - 2014-05-07

- Fixed: SSIDs specified as string in config now produces correct output.


<a name="v0.4.0"></a>
## [v0.4.0] - 2014-05-07

- Added support for configuration persistance, via ENV or `~/.ovpnmcgen.rb.yml` or `--config` flag.
- Updated VoD rules in `--[un]trusted-ssids` to also use `InterfaceTypeMatch`.


<a name="v0.3.0"></a>
## [v0.3.0] - 2014-05-04

- Updated documentation for `URLStringProbe` and `--url-probe`.
- Added URLStringProbe support via `--url-probe` flag.


<a name="v0.2.1"></a>
## [v0.2.1] - 2014-04-19

- Use a portable and native uuidgen implementation.
- Minor fixes for bugs caught by tests.


<a name="v0.2.0"></a>
## [v0.2.0] - 2014-04-18

- TLS-Auth keyfile now optional.
- Added support for security-levels.
- Support custom UUID values.


<a name="v0.1.0"></a>
## [v0.1.0] - 2014-03-27

- Added support for --ovpnconfigfile.
- Improved invalid arguments error message.
- Shorter switches for --[un]trusted-ssids.
- Support custom --port and --proto switches.


<a name="v0.0.2"></a>
## [v0.0.2] - 2014-03-26

- Require at least ruby v1.9.3.


<a name="v0.0.1"></a>
## v0.0.1 - 2014-03-26

- Initial release


[Unreleased]: https://github.com/iphoting/ovpnmcgen.rb/compare/v0.7.1...HEAD
[v0.7.1]: https://github.com/iphoting/ovpnmcgen.rb/compare/v0.7.0...v0.7.1
[v0.7.0]: https://github.com/iphoting/ovpnmcgen.rb/compare/v0.6.0...v0.7.0
[v0.6.0]: https://github.com/iphoting/ovpnmcgen.rb/compare/v0.5.0...v0.6.0
[v0.5.0]: https://github.com/iphoting/ovpnmcgen.rb/compare/v0.5.0.pre...v0.5.0
[v0.5.0.pre]: https://github.com/iphoting/ovpnmcgen.rb/compare/v0.4.2...v0.5.0.pre
[v0.4.2]: https://github.com/iphoting/ovpnmcgen.rb/compare/v0.4.1...v0.4.2
[v0.4.1]: https://github.com/iphoting/ovpnmcgen.rb/compare/v0.4.0...v0.4.1
[v0.4.0]: https://github.com/iphoting/ovpnmcgen.rb/compare/v0.3.0...v0.4.0
[v0.3.0]: https://github.com/iphoting/ovpnmcgen.rb/compare/v0.2.1...v0.3.0
[v0.2.1]: https://github.com/iphoting/ovpnmcgen.rb/compare/v0.2.0...v0.2.1
[v0.2.0]: https://github.com/iphoting/ovpnmcgen.rb/compare/v0.1.0...v0.2.0
[v0.1.0]: https://github.com/iphoting/ovpnmcgen.rb/compare/v0.0.2...v0.1.0
[v0.0.2]: https://github.com/iphoting/ovpnmcgen.rb/compare/v0.0.1...v0.0.2
