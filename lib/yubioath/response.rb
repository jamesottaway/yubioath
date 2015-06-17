require 'bindata'

class YubiOATH
  class Response < BinData::Record
    count_bytes_remaining :data_length
    string :data, read_length: -> { data_length - 2 }
    array :success, type: :uint8, initial_length: 2

    def success?
      success == [0x90, 0x00]
    end
  end
end
