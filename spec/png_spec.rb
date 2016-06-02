require 'spec_helper'

RSpec.describe Branding::PNG do
  it 'returns a pixel list' do
    png = Branding::PNG.from_file(fixture_file('test3x3.png'))
    expect(png.pixels).to eq([
      0x111111ff, 0xc6c6c6ff, 0xffffffff,
      0xc6c6c6ff, 0x111111ff, 0xc6c6c6ff,
      0xffffffff, 0xc6c6c6ff, 0x111111ff
    ])
  end
end
