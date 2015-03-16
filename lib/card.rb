require 'smartcard'

class Card
  def initialize
    Context.new do |context|
      begin
        fail 'Unable to find exactly ONE smart card' unless context.readers.count == 1
        name = context.readers.first
        card = context.card(name)
        yield card
      ensure
        card.disconnect unless card.nil?
      end
    end
  end

  class Context
    def initialize
      context = Smartcard::PCSC::Context.new
      yield context
    ensure
      context.release
    end
  end
end
