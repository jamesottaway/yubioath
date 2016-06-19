require 'bindata'
require 'yubioath'

class YubiOATH
  class List
    def initialize(card)
      @card = card
    end

    def call
      request = Request.new
      bytes = @card.transmit(request.to_binary_s)
      response = Response.read(bytes)

      response[:codes].map do |code|
        [code.name, {
          type: TYPES.key(code.type),
          algorithm: ALGORITHMS.key(code.algorithm),
        }]
      end.to_h
    end

    class Request < BinData::Record
      uint8 :cla, value: 0x00
      uint8 :ins, value: 0xA1
      uint8 :p1, value: 0x00
      uint8 :p2, value: 0x00
    end

    class Response < BinData::Record
      array :codes, read_until: :eof do
        uint8 :name_tag
        uint8 :name_length
        bit4 :type
        bit4 :algorithm
        string :name, read_length: -> { name_length - 1 }
      end
    end
  end
end
