require 'smartcard'

class Card
  def initialize(name:)
    @name = name
  end

  def tap
    Context.tap do |context|
      begin
        card = context.card(@name, :shared)
        yield card
      ensure
        card.disconnect unless card.nil?
      end
    end
  end

  class Context
    def self.tap
      context = Smartcard::PCSC::Context.new
      yield context
    ensure
      context.release
    end
  end
end
