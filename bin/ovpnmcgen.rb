#!/usr/bin/env ruby

require 'ovpnmcgen'
require 'commander/import'

program :version, Ovpnmcgen::VERSION
program :description, Ovpnmcgen::SUMMARY
program :help_formatter, :compact
never_trace!
#global_option '-c', '--config FILE', 'Specify path to config file' #not implemented yet
 
command :generate do |c|
  c.syntax = 'ovpnmcgen.rb generate [options] <user> <device> <p12file> <p12pass>'
  c.summary = 'Generates iOS Configuration Profiles'
  c.description = 'Outputs a .mobileconfig plist to stdout.'
  c.example 'Typical Usage', 'ovpnmcgen.rb gen --trusted-ssids home,school --untrusted-ssids virusnet --host vpn.example.com --cafile path/to/ca.pem --tafile path/to/ta.key john ipad path/to/john-ipad.p12 p12passphrase'
  c.option '--cafile FILE', 'Path to OpenVPN CA file.'
  c.option '--tafile FILE', 'Path to TLS Key file.'
  c.option '--host HOSTNAME', 'Hostname of OpenVPN server.'
  c.option '--[no-]vod', 'Enable or Disable VPN-On-Demand.'
  c.option '--trusted-ssids SSIDS', Array, 'List of comma-separated trusted SSIDs.'
  c.option '--untrusted-ssids SSIDS', Array, 'List of comma-separated untrusted SSIDs.'
  c.option '-o', '--output FILE', 'Output to file.'
  c.action do |args, options|
  	raise ArgumentError.new "Invalid arguments. Run #{File.basename(__FILE__)} help for guidance." if args.nil? or args.length < 4
  	raise ArgumentError.new "Host is required." unless options.host
  	raise ArgumentError.new "cafile is required." unless options.cafile
  	raise ArgumentError.new "tafile is required." unless options.tafile
  	options.default :vod => true
  	user, device, p12file, p12pass = args
  	inputs = {
  		:user => user,
  		:device => device,
  		:p12file => p12file,
  		:p12pass => p12pass,
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
