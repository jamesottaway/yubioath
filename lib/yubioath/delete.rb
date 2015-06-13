require 'yubioath'
require 'bindata'

module YubiOATH
  class Delete
    def self.send(name:, to:)
      data = Request::Data.new(name: name)
      request = Request.new(data: data.to_binary_s)
      ::YubiOATH::Response.read(to.transmit(request.to_binary_s))
    end

    class Request < BinData::Record
      uint8 :cla, value: CLA
      uint8 :ins, value: 0x02
      uint8 :p1, value: 0x00
      uint8 :p2, value: 0x00
      uint8 :data_length, value: -> { data.length }
      string :data

      class Data < BinData::Record
        uint8 :name_tag, value: 0x71
        uint8 :name_length, value: -> { name.length }
        string :name
      end
    end
  end
end
