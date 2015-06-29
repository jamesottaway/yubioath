require 'thor'
require 'card'

class CLI < Thor
  package_name 'yubioath'

  desc 'list', 'list current OTP tokens'
  def list
    card.yubioath do |yubioath|
      all = yubioath.calculate_all(timestamp: Time.now)

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
    card.yubioath do |yubioath|
      token = yubioath.calculate(name: name, timestamp: Time.now)
      STDOUT.print token.code
    end
  end

  desc 'add NAME SECRET', 'add a new OTP secret'
  def add(name, secret)
    card.yubioath do |yubioath|
      response = yubioath.put(name: name, secret: secret, algorithm: 'SHA256', type: 'totp', digits: 6)
      throw unless response.success?
    end
  end

  desc 'delete NAME', 'remove the OTP token called NAME'
  def delete(name)
    card.yubioath do |yubioath|
      response = yubioath.delete(name: name)
      throw unless response.success?
    end
  end

  private

  def card
    @card ||= Card.new(name: 'Yubico Yubikey NEO OTP+CCID')
  end
end
