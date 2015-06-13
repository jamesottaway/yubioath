require 'bindata'

module YubiOATH
  CLA = 0x00
  AID = [0xA0, 0x00, 0x00, 0x05, 0x27, 0x21, 0x01, 0x01]

  class Response < BinData::Record
    count_bytes_remaining :data_length
    string :data, read_length: -> { data_length - 2 }
    array :success, type: :uint8, initial_length: 2

    def success?
      success == [0x90, 0x00]
    end
  end
end
