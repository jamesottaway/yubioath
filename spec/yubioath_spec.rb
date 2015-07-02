require 'yubioath'

RSpec.describe(YubiOATH, :aggregate_failures, order: :defined) do
  let(:aid) { [0xA0, 0x00, 0x00, 0x05, 0x27, 0x21, 0x01, 0x01] }
  let(:select) { [0x00, 0xA4, 0x04, 0x00, aid.length, *aid].map(&:chr).join }
  let(:success) { [0x90, 0x00].map(&:chr) }

  before do
    yubikey.tap do |card|
      card.transmit(select)
      list = card.transmit([0x00, 0xA1, 0x00, 0x00].map(&:chr).join)
      @skip = false
      if (list.chars - success).any?
        @skip = true
        raise 'card not empty'
      end
    end
  end

  let(:yubikey) { Card.new(name: 'Yubico Yubikey NEO OTP+CCID') }
  def yubioath
    yubikey.tap do |card|
      yield YubiOATH.new(card)
    end
  end

  after do
    yubikey.tap do |card|
      unless @skip
        card.transmit(select)
        reset = card.transmit([0x00, 0x04, 0xDE, 0xAD].map(&:chr).join)
        raise 'unable to reset after test suite' unless reset.chars == success
      end
    end
  end
end
