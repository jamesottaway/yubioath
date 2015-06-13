require 'yubioath'
require 'bindata'

module YubiOATH
  class Put
    ALGORITHMS = {'SHA1' => 0x01, 'SHA256' => 0x02}
    TYPES = {'hotp' => 0x10, 'totp' => 0x20}

    def self.send(name:, secret:, algorithm:, type:, digits:, to:)
      data = Request::Data.new(
        name: name,
        key_algorithm: (ALGORITHMS[algorithm] | TYPES[type]),
        digits: digits,
        secret: secret,
      )
      request = Request.new(data: data.to_binary_s)
      ::YubiOATH::Response.read(to.transmit(request.to_binary_s))
    end

    class Request < BinData::Record
      uint8 :cla, value: CLA
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
        uint8 :key_algorithm

        uint8 :digits
        string :secret
      end
    end
  end
end
