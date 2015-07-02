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

  let(:params) { {algorithm: :sha256, type: :totp, digits: 6} }
  let(:t1) { Time.parse('2013-01-01T00:00:00Z') }
  let(:t2) { Time.parse('2014-06-15T12:00:00Z') }
  let(:t3) { Time.parse('2015-12-31T23:59:59Z') }

  it 'calculates OTP tokens' do
    yubioath do |applet|
      { 'foo' => '123', 'bar' => '456', 'qux' => '789' }.each do |name, secret|
        applet.put(name: name, secret: secret, **params)
      end

      expect(applet.calculate(name: 'foo', timestamp: t1)).to eq '947217'
      expect(applet.calculate(name: 'bar', timestamp: t1)).to eq '576740'
      expect(applet.calculate(name: 'qux', timestamp: t1)).to eq '129094'

      expect(applet.calculate(name: 'foo', timestamp: t2)).to eq '904502'
      expect(applet.calculate(name: 'bar', timestamp: t2)).to eq '958008'
      expect(applet.calculate(name: 'qux', timestamp: t2)).to eq '552048'

      expect(applet.calculate(name: 'foo', timestamp: t3)).to eq '204573'
      expect(applet.calculate(name: 'bar', timestamp: t3)).to eq '329294'
      expect(applet.calculate(name: 'qux', timestamp: t3)).to eq '169757'
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
