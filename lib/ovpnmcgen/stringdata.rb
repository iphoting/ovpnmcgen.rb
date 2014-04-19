
module Ovpnmcgen
  class StringData < String
    def to_plist_node
      return "<data>\n#{self}</data>"
    end
  end
end