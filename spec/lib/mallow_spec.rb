require 'spec_helper'
describe Mallow do
  
  describe '::fluff' do
    it 'is an interface to Mallow::Fluffer::build' do
      Mallow::Fluffer.should_receive(:build)
      Mallow.fluff
    end
  end

end
