require 'spec_helper'

RSpec.describe Branding::Pixel do
  it 'shows its value as a uint32 hex number' do
    pixel = Branding::Pixel.new(0x00112200)
    expect(pixel.inspect).to eq('0x00112200')
  end

  it 'initializes with a hex value' do
  end
end
