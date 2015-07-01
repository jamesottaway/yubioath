require 'yubioath/response'

RSpec.describe YubiOATH::Response do
  let(:head) { [0x00, 0x01, 0x02, 0x03, 0x04] }
  let(:tail) { [0x00, 0x00] }

  let(:response) { [*head, *tail].map(&:chr).join }
  subject { YubiOATH::Response.read(response) }

  its(:data) { is_expected.to eq "\x00\x01\x02\x03\x04" }

  context 'success' do
    let(:tail) { [0x90, 0x00] }
    its(:success?) { is_expected.to eq true }
  end

  context 'auth required' do
    let(:tail) { [0x69, 0x82] }
    its(:success?) { is_expected.to eq false }
  end

  context 'wrong syntax' do
    let(:tail) { [0x6A, 0x80] }
    its(:success?) { is_expected.to eq false }
  end
end
