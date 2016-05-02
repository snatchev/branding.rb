require 'spec_helper'

describe Branding do
  it 'should have a version number' do
    Branding::VERSION.should_not be_nil
  end
end
