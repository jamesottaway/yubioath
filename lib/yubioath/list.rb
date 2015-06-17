require 'yubioath'
require 'bindata'

class YubiOATH
  class List
    def self.send(to:)
      response = ::YubiOATH::Response.read(to.transmit(Request.new.to_binary_s))
      throw unless response.success?
      Response.read(response.data)
    end

    class Request < BinData::Record
      uint8 :cla, value: CLA
      uint8 :ins, value: 0xA1
      uint8 :p1, value: 0x00
      uint8 :p2, value: 0x00
    end

    class Response < BinData::Record
      array :codes, read_until: :eof do
        uint8 :name_tag
        uint8 :name_length
        string :name, read_length: :name_length
      end
    end
  end
end
