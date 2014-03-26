#!/usr/bin/env ruby

require 'ovpnmcgen'
require 'commander/import'

program :version, Ovpnmcgen::VERSION
program :description, Ovpnmcgen::SUMMARY
program :help, 'Usage', 'ovpnmcgen.rb <command> [options] <args...>'
program :help_formatter, :compact
default_command :help
never_trace!
#global_option '-c', '--config FILE', 'Specify path to config file' #not implemented yet
 
command :generate do |c|
  c.syntax = 'ovpnmcgen.rb generate [options] <user> <device>'
  c.summary = 'Generates iOS Configuration Profiles'
  c.description = 'Generates a .mobileconfig plist.'
  c.example 'Typical Usage', 'ovpnmcgen.rb gen --trusted-ssids home --host vpn.example.com --cafile path/to/ca.pem --tafile path/to/ta.key --p12file path/to/john-ipad.p12 --p12pass p12passphrase john ipad'
  c.example 'Extended Usage', 'ovpnmcgen.rb gen --trusted-ssids home,school --untrusted-ssids virusnet --host vpn.example.com --cafile path/to/ca.pem --tafile path/to/ta.key --p12file path/to/john-ipad.p12 --p12pass p12passphrase john ipad'
  c.example 'Creating a .p12 file using OpenSSL', 'openssl pkcs12 -export -out path/to/john-ipad.p12 -inkey path/to/john-ipad.key -in path/to/john-ipad.crt -passout pass:p12passphrase'
  c.option '--cafile FILE', 'Path to OpenVPN CA file. (Required)'
  c.option '--tafile FILE', 'Path to TLS Key file. (Required)'
  c.option '--host HOSTNAME', 'Hostname of OpenVPN server. (Required)'
  c.option '--p12file FILE', 'Path to user PKCS#12 file. (Required)'
  c.option '--p12pass PASSWORD', 'Password to unlock PKCS#12 file.'
  c.option '--[no-]vod', 'Enable or Disable VPN-On-Demand. [Default: Enabled]'
  c.option '--trusted-ssids SSIDS', Array, 'List of comma-separated trusted SSIDs.'
  c.option '--untrusted-ssids SSIDS', Array, 'List of comma-separated untrusted SSIDs.'
  c.option '-o', '--output FILE', 'Output to file. [Default: stdout]'
  c.action do |args, options|
  	raise ArgumentError.new "Invalid arguments. Run #{File.basename(__FILE__)} help for guidance." if args.nil? or args.length < 2
  	raise ArgumentError.new "Host is required." unless options.host
  	raise ArgumentError.new "cafile is required." unless options.cafile
  	raise ArgumentError.new "tafile is required." unless options.tafile
    raise ArgumentError.new "PKCS#12 file is required." unless options.p12file
  	options.default :vod => true
  	user, device, p12file, p12pass = args
  	inputs = {
  		:user => user,
  		:device => device,
  		:p12file => options.p12file,
  		:p12pass => options.p12pass,
  		:cafile => options.cafile,
  		:tafile => options.tafile,
  		:host => options.host,
  		:enableVOD => options.vod,
  		:trusted_ssids => options.trusted_ssids,
  		:untrusted_ssids => options.untrusted_ssids
  	}
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
