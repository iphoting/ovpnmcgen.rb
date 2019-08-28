
module Ovpnmcgen
  def getOVPNVendorConfigHash(ovpnfilepath)
    ovpnfile = ""
    begin
      # get rid of comments in the file.
      ovpnfile = File.readlines(ovpnfilepath).delete_if { |l| ; l.start_with?('#') or l.start_with?(';') or l.chomp.empty? }

      # TODO: [Warning] Get rid of/handle <ca>...</ca>, <cert>...</cert>, <key>...</key>, <tls-auth>...</tls-auth> inline cert/key enclosures.
      # Bail when inline cert/key enclosures are detected.
      ovpnfile.each do |l|
        r = l.chomp.match(/<.*>/)
        raise ArgumentError.new "OpenVPN client config file contains inline data enclosures: #{r.to_a.join(', ')}!\nSuch files are not yet supported. Remove them and try again" unless r.nil?
      end

      # TODO: Handle multiple remote lines.
      # Currently, all remote lines are ignored.

      # map to key => value pairs for plist purposes. Singular verbs will be: 'verb' => 'NOARGS'.
      ovpnhash = Hash[ovpnfile.map do |l|
        a = l.split
        if a.length == 1
          a << "NOARGS"
        elsif a.length > 2
          b = a.take(1)
          c = a.drop(1).join ' '
          a.replace(b << c)
        end
        a
      end]

      # delete obviously unsupported keys.
      ovpnhash.delete_if do |key, value|
        case key
        when 'fragment', 'mssfix', 'secret', 'socks-proxy', 'persist-key', 'persist-tun', 'resolv-retry', 'nobind', 'verb', 'user', 'group', 'pull', 'mute'
          true
        when 'remote', 'ca', 'pkcs12', 'tls-auth', 'tls-crypt', 'cert', 'key', 'proto' # specified with switches.
          true
        else
          false
        end
      end
    rescue Errno::ENOENT
      puts "OpenVPN config file not found: #{ovpnfilepath}!"
      exit
    end
    return ovpnhash
  end

  module_function :getOVPNVendorConfigHash
end
