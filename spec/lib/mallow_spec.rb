require 'spec_helper'
describe Mallow do
  
  describe '::fluff' do
    it 'is an interface to Mallow::Fluffer::build' do
      config = { parser: Object, verb: :this_wont_work }
      Mallow::Fluffer.stub build: nil
      Mallow::Fluffer.should_receive(:build).with config
      Mallow.fluff(config) {}
    end
  end

end
