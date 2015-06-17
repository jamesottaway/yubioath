require 'yubioath'
require 'bindata'

class YubiOATH
  class Reset
    def self.send(to:)
      ::YubiOATH::Response.read(to.transmit(Request.new.to_binary_s))
    end

    class Request < BinData::Record
      uint8 :cla, value: CLA
      uint8 :ins, value: 0x04
      uint8 :p1, value: 0xDE
      uint8 :p2, value: 0xAD
    end
  end
end
