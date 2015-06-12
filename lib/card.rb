require 'smartcard'

class Card
  def initialize(name:)
    Context.new do |context|
      begin
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
