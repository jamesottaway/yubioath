require 'bindata'

class YubiOATH
  class CalculateAll
    def self.send(timestamp:, to:)
      data = Request::Data.new(timestamp: timestamp.to_i / 30)
      request = Request.new(data: data.to_binary_s)
      response = ::YubiOATH::Response.read(to.transmit(request.to_binary_s))
      throw unless response.success?
      Response.read(response.data)
    end

    class Request < BinData::Record
      uint8 :cla, value: 0x00
      uint8 :ins, value: 0xA4
      uint8 :p1, value: 0x00
      uint8 :p2, value: 0x01
      uint8 :data_length, value: -> { data.length }
      string :data

      class Data < BinData::Record
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

      array :codes, read_until: :eof do
        uint8 :name_tag
        uint8 :name_length
        string :name, read_length: :name_length

        uint8 :response_tag
        uint8 :response_length
        code :code, read_length: :response_length
      end
    end
  end
end
