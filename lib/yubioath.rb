require 'bindata'
require 'yubioath/instructions'
require 'yubioath/response'

class YubiOATH
  AID = [0xA0, 0x00, 0x00, 0x05, 0x27, 0x21, 0x01, 0x01]
  ALGORITHMS = { SHA1: 0x1, SHA256: 0x2 }
  TYPES = { HOTP: 0x1, TOTP: 0x2 }

  def initialize(card)
    @card = card
    select(AID)
  end

  def calculate(name:, timestamp: Time.now)
    data = Calculate::Request::Data.new(name: name, timestamp: timestamp.to_i / 30)
    request = Calculate::Request.new(data: data.to_binary_s)
    response = Response.read(@card.transmit(request.to_binary_s))
    Calculate::Response.read(response.data).code.to_s
  end

  def calculate_all(timestamp: Time.now)
    data = CalculateAll::Request::Data.new(timestamp: timestamp.to_i / 30)
    request = CalculateAll::Request.new(data: data.to_binary_s)
    response = Response.read(@card.transmit(request.to_binary_s))
    CalculateAll::Response.read(response.data)[:codes].map do |code|
      [code.name, code.code.to_s]
    end.to_h
  end

  def delete(name:)
    data = Delete::Request::Data.new(name: name)
    request = Delete::Request.new(data: data.to_binary_s)
    Response.read(@card.transmit(request.to_binary_s))
  end

  def list
    request = List::Request.new.to_binary_s
    response = Response.read(@card.transmit(request))
    List::Response.read(response.data)[:codes].map do |code|
      [code.name, {
        type: TYPES.key(code.type),
        algorithm: ALGORITHMS.key(code.algorithm),
      }]
    end.to_h
  end

  def put(name:, secret:, algorithm: :SHA256, type: :TOTP, digits: 6)
    data = Put::Request::Data.new(
      name: name,
      type: TYPES.fetch(type),
      algorithm: ALGORITHMS.fetch(algorithm),
      digits: digits,
      secret: secret,
    )
    request = Put::Request.new(data: data.to_binary_s)
    Response.read(@card.transmit(request.to_binary_s))
  end

  def reset(confirm: false)
    Response.read(@card.transmit(Reset::Request.new.to_binary_s)) if confirm
  end

  private

  def select(aid)
    request = Select::Request.new(aid: aid).to_binary_s
    response = Response.read(@card.transmit(request))
    Select::Response.read(response.data)
  end
end
