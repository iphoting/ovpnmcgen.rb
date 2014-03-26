require "ovpnmcgen/version"
require 'plist'
require 'base64'

module Ovpnmcgen
  class StringData < String
    def to_plist_node
      return "<data>\n#{self}\n</data>"
    end
  end

  def generate(inputs = {})
    identifier = inputs[:identifier] || inputs[:host].split('.').reverse!.join('.')
    port = inputs[:port] || 1194
    certUUID = inputs[:certUUID] || `uuidgen`.chomp.upcase
    user, device, domain, host = inputs[:user], inputs[:device], inputs[:host], inputs[:host]
    enableVOD = inputs[:enableVOD]
    trusted_ssids = inputs[:trusted_ssids] || false
    untrusted_ssids = inputs[:untrusted_ssids] || false

    begin
      ca_cert = File.readlines(inputs[:cafile]).map { |x| x.chomp }.join('\n')
    rescue Errno::ENOENT
      puts "CA file not found: #{inputs[:cafile]}!"
      exit
    end

    begin
      tls_auth = File.readlines(inputs[:tafile]).map { |x| x.chomp }.join('\n')
    rescue Errno::ENOENT
      puts "TLS file not found: #{inputs[:tafile]}!"
      exit
    end

    begin
      p12file = Base64.encode64(File.read(inputs[:p12file]))
    rescue Errno::ENOENT
      puts "PCKS#12 file not found: #{inputs[:p12file]}!"
      exit
    end

    vpnOnDemandRules = Array.new
    vodTrusted = { # Trust only Wifi SSID
      'SSIDMatch' => trusted_ssids,
      'Action' => 'Disconnect'
    }
    vodUntrusted = { # Untrust Wifi
      'SSIDMatch' => untrusted_ssids,
      'Action' => 'Connect'
    }
    vpnOnDemandRules << vodTrusted if trusted_ssids
    vpnOnDemandRules << vodUntrusted if untrusted_ssids

    vpnOnDemandRules << { # Untrust all Wifi
      'InterfaceTypeMatch' => 'WiFi',
      'Action' => 'Connect'
    } << { # Trust Cellular
      'InterfaceTypeMatch' => 'Cellular',
      'Action' => 'Ignore'
    } << { # Default catch-all
      'Action' => 'Connect'
    }

    cert = {
      'Password' => inputs[:p12pass],
      'PayloadCertificateFileName' => "#{user}-#{device}.p12",
      'PayloadContent' => StringData.new(p12file),
      'PayloadDescription' => 'Provides device authentication (certificate or identity).',
      'PayloadDisplayName' => "#{user}-#{device}.p12",
      'PayloadIdentifier' => "#{identifier}.#{user}-#{device}.credential",
      'PayloadOrganization' => domain,
      'PayloadType' => 'com.apple.security.pkcs12',
      'PayloadUUID' => certUUID,
      'PayloadVersion' => 1
    }

    vpn = {
      'PayloadDescription' => "Configures VPN settings, including authentication.",
      'PayloadDisplayName' => "VPN (#{host}/VoD)",
      'PayloadIdentifier' => "#{identifier}.#{user}-#{device}.vpnconfig",
      'PayloadOrganization' => domain,
      'PayloadType' => 'com.apple.vpn.managed',
      'PayloadUUID' => `uuidgen`.chomp.upcase,
      'PayloadVersion' => 1,
      'UserDefinedName' => "#{host}/VoD",
      'VPN' => {
        'AuthenticationMethod' => 'Certificate',
        'OnDemandEnabled' => (enableVOD)? 1 : 0,
        'OnDemandRules' => vpnOnDemandRules,
        'PayloadCertificateUUID' => certUUID,
        'RemoteAddress' => 'DEFAULT'
      },
      'VPNSubType' => 'net.openvpn.OpenVPN-Connect.vpnplugin',
      'VPNType' => 'VPN',
      'VendorConfig' => {
        'ca' => ca_cert,
        'client' => 'NOARGS',
        'comp-lzo' => 'NOARGS',
        'dev' => 'tun',
        'key-direction' => '1',
        'persist-key' => 'NOARGS',
        'persist-tun' => 'NOARGS',
        'proto' => 'udp',
        'remote' => "#{host} #{port} udp",
        'remote-cert-tls' => 'server',
        'resolv-retry' => 'infinite',
        'tls-auth' => tls_auth,
        'verb' => '3'
      }
    }

    plistPayloadContent = [vpn, cert] # to encrypt this array
    #encPlistPayloadContent = cmsEncrypt([vpn, cert].to_plist).der_format

    plist = {
      'PayloadDescription' => "OpenVPN Configuration Payload for #{user}-#{device}@#{host}",
      'PayloadDisplayName' => "#{host} OpenVPN #{user}@#{device}",
      'PayloadIdentifier' => "#{identifier}.#{user}-#{device}",
      'PayloadOrganization' => domain,
      'PayloadRemovalDisallowed' => false,
      'PayloadType' => 'Configuration',
      'PayloadUUID' => `uuidgen`.chomp.upcase,
      'PayloadVersion' => 1,
      #'EncryptedPayloadContent' => StringData.new(encPlistPayloadContent)
      'PayloadContent' => plistPayloadContent
    }

    return plist.to_plist
  end

  module_function :generate
end
