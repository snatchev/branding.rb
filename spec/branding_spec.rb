require 'spec_helper'

describe Branding do
  it 'should have a version number' do
    expect(Branding::VERSION).to_not be_nil
  end
end
