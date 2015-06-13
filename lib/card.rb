require 'smartcard'

class Card
  def initialize(name:)
    @name = name
  end

  def tap(&block)
    Context.tap do |context|
      begin
        card = context.card(@name)
        block.call(card)
      ensure
        card.disconnect unless card.nil?
      end
    end
  end

  class Context
    def self.tap(&block)
      context = Smartcard::PCSC::Context.new
      block.call(context)
    ensure
      context.release
    end
  end
end
