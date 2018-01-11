#!/usr/bin/env ruby

require 'ovpnmcgen'
require 'commander/import'
require 'ovpnmcgen/config'

program :version, Ovpnmcgen::VERSION
program :description, Ovpnmcgen::SUMMARY
program :help, 'Usage', 'ovpnmcgen.rb <command> [options] <args...>'
program :help_formatter, :compact
default_command :help
never_trace!
global_option '-c', '--config FILE', 'Specify path to config file. [Default: .ovpnmcgen.rb.yml]'
 
command :generate do |c|
  c.syntax = 'ovpnmcgen.rb generate [options] <user> <device>'
  c.summary = 'Generates iOS Configuration Profiles (.mobileconfig)'
  c.description = 'Generates iOS configuration profiles (.mobileconfig) that configures OpenVPN for use with VPN-on-Demand that are not accessible through the Apple Configurator or the iPhone Configuration Utility.'
  c.example 'Typical Usage', 'ovpnmcgen.rb gen --trusted-ssids home --host vpn.example.com --cafile path/to/ca.pem --tafile path/to/ta.key --p12file path/to/john-ipad.p12 --p12pass p12passphrase john ipad'
  c.example 'Extended Usage', 'ovpnmcgen.rb gen --trusted-ssids home,school --untrusted-ssids virusnet --host vpn.example.com --cafile path/to/ca.pem --tafile path/to/ta.key --p12file path/to/john-ipad.p12 --p12pass p12passphrase john ipad'
  c.example 'Using OpenSSL to convert files into PKCS#12 (.p12)', 'openssl pkcs12 -export -out path/to/john-ipad.p12 -inkey path/to/john-ipad.key -in path/to/john-ipad.crt -passout pass:p12passphrase -name john-ipad@vpn.example.com'
  c.example 'Using OpenSSL to convert from PKCS#12 (.p12) to Cert PEM file', 'openssl pkcs12 -in path/to/john-ipad.p12 -out path/to/john-ipad-cert.crt -nodes -nokeys'
  c.example 'Using OpenSSL to convert from PKCS#12 (.p12) to Key PEM file', 'openssl pkcs12 -in path/to/john-ipad.p12 -out path/to/john-ipad-key.pem -nodes -nocerts'
  c.option '--cafile FILE', 'Path to OpenVPN CA file. (Required)'
  c.option '--tafile FILE', 'Path to TLS-Auth Key file.'
  c.option '--cert FILE', 'Path to Cert file.'
  c.option '--key FILE', 'Path to Private Key file.'
  c.option '--host HOSTNAME', 'Hostname of OpenVPN server. (Required)'
  c.option '--proto PROTO', 'OpenVPN server protocol. [Default: udp]'
  c.option '-p', '--port PORT', 'OpenVPN server port. [Default: 1194]'
  c.option '--p12file FILE', 'Path to user PKCS#12 file. (Required)'
  c.option '--p12pass PASSWORD', 'Password to unlock PKCS#12 file.'
  c.option '--[no-]vod', 'Enable or Disable VPN-On-Demand. [Default: Enabled]'
  c.option '--v12compat', 'Enable OpenVPN Connect 1.2.x compatibility. [Default: Disabled]'
  c.option '--security-level LEVEL', 'Security level of VPN-On-Demand Behaviour: paranoid, high, medium. [Default: high]'
  c.option '--vpn-uuid UUID', 'Override a VPN configuration payload UUID.'
  c.option '--profile-uuid UUID', 'Override a Profile UUID.'
  c.option '--cert-uuid UUID', 'Override a Certificate payload UUID.'
  c.option '-t', '--trusted-ssids SSIDS', Array, 'List of comma-separated trusted SSIDs.'
  c.option '-u', '--untrusted-ssids SSIDS', Array, 'List of comma-separated untrusted SSIDs.'
  c.option '-d', '--domains DOMAINS', Array, 'List of comma-separated domain names requiring VPN service.'
  c.option '--domain-probe-url PROBE', String, 'An HTTP(S) URL to probe, using a GET request. If no HTTP response code is received from the server, a VPN connection is established in response.'
  c.option '--url-probe URL', 'This URL must return HTTP status 200, without redirection, before the VPN service will try establishing.'
  c.option '--remotes REMOTES', Array, 'List of comma-separated alternate remotes: "<host> <port> <proto>".'
  c.option '--ovpnconfigfile FILE', 'Path to OpenVPN client config file.'
  c.option '-o', '--output FILE', 'Output to file. [Default: stdout]'
  c.action do |args, options|
    raise ArgumentError.new "Invalid arguments. Run '#{File.basename(__FILE__)} help generate' for guidance" if args.nil? or args.length < 2

    # Set up configuration environment.
    if options.config
      Ovpnmcgen.configure(options.config)
    else
      Ovpnmcgen.configure
    end
    config = Ovpnmcgen.config

    raise ArgumentError.new "Host is required" unless options.host or config.host
    raise ArgumentError.new "cafile is required" unless options.cafile or config.cafile

    # A --p12file or (--cert and --key) needs to be provided. Shall not prevent user from specifying both.
    unless (options.p12file or config.p12file) or ((options.cert or config.cert) and (options.key or config.key))
      raise ArgumentError.new "PKCS#12 or cert & key file required"
    end

    options.default :vod => case
      when config.vod == true || config.no_vod == false
        true
      when config.vod == false || config.no_vod == true
        false
      else # enabled by default
        true
      end,
      :proto => (config.proto)? config.proto : 'udp',
      :port => (config.port)? config.port : 1194,
      :security_level => (config.security_level)? config.security_level : 'high'

    user, device = args

    inputs = {
      :user => user,
      :device => device,
      :p12pass => options.p12pass || config.p12pass,
      :cafile => options.cafile || config.cafile,
      :host => options.host || config.host,
      :proto => options.proto,
      :port => options.port,
      :enableVOD => options.vod,
      :trusted_ssids => options.trusted_ssids || config.trusted_ssids,
      :untrusted_ssids => options.untrusted_ssids || config.untrusted_ssids,
      :profile_uuid => options.profile_uuid || config.profile_uuid,
      :vpn_uuid => options.vpn_uuid || config.vpn_uuid,
      :cert_uuid => options.cert_uuid || config.cert_uuid,
      :security_level => options.security_level
    }
    inputs[:ovpnconfigfile] = options.ovpnconfigfile || config.ovpnconfigfile if options.ovpnconfigfile or config.ovpnconfigfile
    inputs[:p12file] = options.p12file || config.p12file if options.p12file or config.p12file
    inputs[:tafile] = options.tafile || config.tafile if options.tafile or config.tafile
    inputs[:cert] = options.cert || config.cert if options.cert or config.cert
    inputs[:key] = options.key || config.key if options.key or config.key
    inputs[:url_probe] = options.url_probe || config.url_probe if options.url_probe or config.url_probe
    inputs[:remotes] = options.remotes || config.remotes if options.remotes or config.remotes
    inputs[:domains] = options.domains || config.domains if options.domains or config.domains
    inputs[:domain_probe_url] = options.domain_probe_url || config.domain_probe_url if options.domain_probe_url or config.domain_probe_url
    inputs[:v12compat] = options.v12compat || config.v12compat if options.v12compat or config.v12compat

    unless options.output
      puts Ovpnmcgen.generate(inputs)
    else
      # write to file
      begin
        File.write(options.output, Ovpnmcgen.generate(inputs))
      rescue Errno::ENOENT
        puts "Error writing to: #{options.output}"
      end
    end
  end
end

alias_command :g, :generate
alias_command :gen, :generate
