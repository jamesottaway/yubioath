require 'bindata'
require 'yubioath/instructions'
require 'yubioath/response'

class YubiOATH
  AID = [0xA0, 0x00, 0x00, 0x05, 0x27, 0x21, 0x01, 0x01]
  ALGORITHMS = { SHA1: 0x1, SHA256: 0x2 }
  TYPES = { HOTP: 0x1, TOTP: 0x2 }

  def initialize(card)
    @card = card
    Select.new(@card).call(aid: AID)
  end

  def calculate(name:, timestamp:)
    Calculate.new(@card).call(name: name, timestamp: timestamp)
  end

  def calculate_all(timestamp:)
    CalculateAll.new(@card).call(timestamp: timestamp)
  end

  def delete(name:)
    Delete.new(@card).call(name: name)
  end

  def list
    List.new(@card).call
  end

  def put(name:, secret:, algorithm: :SHA256, type: :TOTP, digits: 6)
    Put.new(@card).call(name: name, secret: secret, algorithm: algorithm, type: type, digits: digits)
  end

  def reset(confirm: false)
    return false unless confirm
    Reset.new(@card).call
  end
end
