require 'spec_helper'

RSpec.describe Branding::PNG do
  it 'returns a pixel matrix' do
    png = Branding::PNG.from_file(fixture_file('test3x3.png'))
    expect(png.pixels).to eq(
      [
        [0x111111, 0xc6c6c6, 0xffffff],
        [0xc6c6c6, 0x111111, 0xc6c6c6],
        [0xffffff, 0xc6c6c6, 0x111111]
      ]
    )
  end
end
