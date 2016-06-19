require 'bindata'

class YubiOATH
  class Calculate
    def initialize(card)
      @card = card
    end

    def call(name:, timestamp:)
      data = Request::Data.new(name: name, timestamp: timestamp.to_i / 30)
      request = Request.new(data: data.to_binary_s)
      bytes = @card.transmit(request.to_binary_s)
      response = Response.read(bytes)
      response.code.to_s
    end

    class Request < BinData::Record
      uint8 :cla, value: 0x00
      uint8 :ins, value: 0xA2
      uint8 :p1, value: 0x00
      uint8 :p2, value: 0x01
      uint8 :data_length, value: -> { data.length }
      string :data

      class Data < BinData::Record
        uint8 :name_tag, value: 0x71
        uint8 :name_length, value: -> { name.length }
        string :name

        uint8 :challenge_tag, value: 0x74
        uint8 :challenge_length, value: 8
        uint64be :timestamp
      end
    end

    class Response < BinData::Record
      class Code < BinData::Record
        uint8 :digits
        uint32be :response

        def to_s
          (response % 10**digits).to_s.rjust(digits, '0')
        end
      end

      uint8 :response_tag
      uint8 :response_length
      code :code, read_length: :response_length
    end
  end
end
