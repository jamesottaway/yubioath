require 'bindata'
require 'yubioath'
require 'yubioath/response'

class YubiOATH
  class Put
    def initialize(card)
      @card = card
    end

    def call(name:, secret:, algorithm:, type:, digits:)
      data = Request::Data.new(
        name: name,
        type: TYPES.fetch(type),
        algorithm: ALGORITHMS.fetch(algorithm),
        digits: digits,
        secret: secret,
      )
      request = Request.new(data: data.to_binary_s)
      bytes = @card.transmit(request.to_binary_s)
      Response.read(bytes).success?
    end

    class Request < BinData::Record
      uint8 :cla, value: 0x00
      uint8 :ins, value: 0x01
      uint8 :p1, value: 0x00
      uint8 :p2, value: 0x00
      uint8 :data_length, value: -> { data.length }
      string :data

      class Data < BinData::Record
        uint8 :name_tag, value: 0x71
        uint8 :name_length, value: -> { name.length }
        string :name

        uint8 :key_tag, value: 0x73
        uint8 :key_length, value: -> { secret.length + 2 }
        bit4 :type
        bit4 :algorithm
        uint8 :digits
        string :secret
      end
    end
  end
end
