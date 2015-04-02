require 'bindata'

module YubiOATH
  class List
    def self.send(to:)
      to.transmit(Request.new.to_binary_s)
    end

    class Request < BinData::Record
      uint8 :cla, value: CLA
      uint8 :ins, value: 0xA1
      uint8 :p1, value: 0x00
      uint8 :p2, value: 0x00
    end

    class ListEntry < BinData::Primitive
      uint8 :name_list_tag, assert: 0x72
      uint8 :name_length
      string :name, read_length: -> { name_length - 1 }
    end

    class Response < BinData::Record
      array :codes, type: :list_entry
    end
  end
end
