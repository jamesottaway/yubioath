require 'bindata'
require_relative 'validate'

class YubiOATH
  class Select
    def initialize(card)
      @card = card
    end

    def call(aid:)
      request = Request.new(aid: aid)
      bytes = @card.transmit(request.to_binary_s)

      # ugly way to check for challenge
      begin
        response = Response_challenge.read(bytes)

        # we need to validate the pin
        Validate.new(@card).call(select_response: response)

      rescue BinData::ValidityError
        response = Response.read(bytes)
      end

    end

    class Request < BinData::Record
      uint8 :cla, value: 0x00
      uint8 :ins, value: 0xA4
      uint8 :p1, value: 0x04
      uint8 :p2, value: 0x00
      uint8 :aid_length, value: -> { aid.length }
      array :aid, type: :uint8
    end

    class Response_challenge < BinData::Record
      uint8 :version_tag, assert: 0x79
      uint8 :version_length
      array :version, type: :uint8, initial_length: :version_length

      uint8 :name_tag, assert: 0x71
      uint8 :name_length
      string :name, type: :uint8, read_length: :name_length

      uint8 :challenge_tag, assert: 0x74
      uint8 :challenge_length
      string :challenge, type: :uint8, read_length: :challenge_length

      uint8 :algorithm_tag, assert: 0x7b
      uint8 :algorithm_length
      string :algorithm, type: :uint8, read_length: :algorithm_length
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
