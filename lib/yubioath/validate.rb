require 'bindata'
require 'io/console'
require 'openssl'

class YubiOATH
  class Validate
    def initialize(card)
      @card = card
    end

    def call(select_response:)
      # we need to validate pin
      pin = STDIN.getpass("Please enter PIN:")

      # derive key from password - salt is name from select response
      key = OpenSSL::PKCS5.pbkdf2_hmac_sha1(pin, select_response.name.to_binary_s, 1000, 16)

      # compute hash of key & challenge for response
      h = OpenSSL::HMAC.new(key, OpenSSL::Digest.new('sha1'))
      h.update(select_response.challenge.to_binary_s)
      validate_response = h.digest
      h.reset

      # generate challenge for mutual verification
      challenge = Random.new.bytes(8)
      h.update(challenge)
      verification = h.digest

      data = Request::Data.new(response: validate_response, challenge: challenge)
      request = Request.new(data: data.to_binary_s)
      bytes = @card.transmit(request.to_binary_s)

      response = Response.read(bytes)
      unless response.response == verification
        fail 'Response from validation does not match verification!'
      end
    end

    class Request < BinData::Record
      uint8 :cla, value: 0x00
      uint8 :ins, value: 0xA3
      uint8 :p1, value: 0x00
      uint8 :p2, value: 0x00
      uint8 :data_length, value: -> { data.length }
      string :data

      class Data < BinData::Record
        uint8 :response_tag, value: 0x75
        uint8 :response_length, value: -> { response.length }
        string :response

        uint8 :challenge_tag, value: 0x74
        uint8 :challenge_length, value: -> { challenge.length }
        string :challenge
      end
    end

    class Response < BinData::Record
      uint8 :response_tag, assert: 0x75
      uint8 :response_length
      string :response, type: :uint8, read_length: :response_length
    end
  end
end
