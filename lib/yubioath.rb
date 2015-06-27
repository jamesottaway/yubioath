require 'bindata'
require 'yubioath/instructions'
require 'yubioath/response'

class YubiOATH
  CLA = 0x00
  AID = [0xA0, 0x00, 0x00, 0x05, 0x27, 0x21, 0x01, 0x01]

  def initialize(card)
    @card = card
    select(AID)
  end

  def calculate(name:, timestamp:)
    data = Calculate::Request::Data.new(name: name, timestamp: timestamp.to_i / 30)
    request = Calculate::Request.new(data: data.to_binary_s)
    response = Response.read(@card.transmit(request.to_binary_s))
    throw unless response.success?
    Calculate::Response.read(response.data)
  end

  def calculate_all(timestamp:)
    data = CalculateAll::Request::Data.new(timestamp: timestamp.to_i / 30)
    request = CalculateAll::Request.new(data: data.to_binary_s)
    response = Response.read(@card.transmit(request.to_binary_s))
    throw unless response.success?
    CalculateAll::Response.read(response.data)
  end

  def delete(name:)
    data = Delete::Request::Data.new(name: name)
    request = Delete::Request.new(data: data.to_binary_s)
    Response.read(@card.transmit(request.to_binary_s))
  end

  def list
    request = List::Request.new.to_binary_s
    response = Response.read(@card.transmit(request))
    throw unless response.success?
    List::Response.read(response.data)
  end

  def put(name:, secret:, algorithm:, type:, digits:)
    data = Put::Request::Data.new(
      name: name,
      key_algorithm: (Put::ALGORITHMS[algorithm] | Put::TYPES[type]),
      digits: digits,
      secret: secret,
    )
    request = Put::Request.new(data: data.to_binary_s)
    Response.read(@card.transmit(request.to_binary_s))
  end

  def reset
    Response.read(@card.transmit(Reset::Request.new.to_binary_s))
  end

  private

  def select(aid)
    request = Select::Request.new(aid: aid).to_binary_s
    response = Response.read(@card.transmit(request))
    throw unless response.success?
    Select::Response.read(response.data)
  end
end
