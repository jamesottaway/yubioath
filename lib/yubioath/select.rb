require 'yubioath'
require 'bindata'

class YubiOATH
  class Select
    def self.send(aid:, to:)
      response = ::YubiOATH::Response.read(to.transmit(Request.new(aid: aid).to_binary_s))
      throw unless response.success?
      Response.read(response.data)
    end

    class Request < BinData::Record
      uint8 :cla, value: CLA
      uint8 :ins, value: 0xA4
      uint8 :p1, value: 0x04
      uint8 :p2, value: 0x00
      uint8 :aid_length, value: -> { aid.length }
      array :aid, type: :uint8
    end

    class Response < BinData::Record
      uint8 :version_tag, assert: 0x79
      uint8 :version_length
      array :version, type: :uint8, initial_length: :version_length

      uint8 :name_tag, assert: 0x71
      uint8 :name_length
      array :name, type: :uint8, initial_length: :name_length
    end
  end
end
