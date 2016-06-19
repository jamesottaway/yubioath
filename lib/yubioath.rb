require 'yubioath/calculate'
require 'yubioath/calculate_all'
require 'yubioath/delete'
require 'yubioath/list'
require 'yubioath/put'
require 'yubioath/reset'
require 'yubioath/select'

class YubiOATH
  AID = [0xA0, 0x00, 0x00, 0x05, 0x27, 0x21, 0x01, 0x01]

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

  def reset
    Reset.new(@card).call
  end
end
