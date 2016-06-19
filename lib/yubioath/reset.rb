require 'bindata'
require 'yubioath/response'

class YubiOATH
  class Reset
    def initialize(card)
      @card = card
    end

    def call
      request = Reset::Request.new
      bytes = @card.transmit(request.to_binary_s)
      Response.read(bytes).success?
    end

    class Request < BinData::Record
      uint8 :cla, value: 0x00
      uint8 :ins, value: 0x04
      uint8 :p1, value: 0xDE
      uint8 :p2, value: 0xAD
    end
  end
end
