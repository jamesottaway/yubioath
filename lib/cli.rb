require 'thor'
require 'card'
require 'yubioath'
require 'yubioath/select'

class CLI < Thor
  CARD = Card.new(name: 'Yubico Yubikey NEO OTP+CCID')

  package_name 'yubioath'

  desc 'list', 'list current OTP tokens'
  def list
    require 'yubioath/calculate_all'
    CARD.tap do |card|
      YubiOATH::Select.send(aid: ::YubiOATH::AID, to: card)
      all = YubiOATH::CalculateAll.send(timestamp: Time.now, to: card)

      STDOUT.puts
      STDOUT.puts 'YubiOATH Tokens:'
      STDOUT.puts '----------------'

      all[:codes].each_with_index do |token, index|
        STDOUT.puts "#{index+1}. #{token.name}: #{token.code}"
      end
    end
  end

  desc 'token NAME', 'get the current OTP value for NAME'
  def token(name)
    require 'yubioath/calculate'
    CARD.tap do |card|
      YubiOATH::Select.send(aid: ::YubiOATH::AID, to: card)
      token = YubiOATH::Calculate.send(name: name, timestamp: Time.now, to: card)
      STDOUT.puts token.code
    end
  end
end
