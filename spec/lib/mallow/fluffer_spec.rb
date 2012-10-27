require 'spec_helper'

describe Mallow::Fluffer do

  before do
    @fluffer = Mallow::Fluffer.build {}
  end

  describe '::build' do
    it 'is an interface to Mallow::Rule::Builder' do
      @builder = Mallow::Rule::Builder.new
      Mallow::Rule::Builder.should_receive(:new).and_return @builder
      Mallow::Fluffer.should_receive(:new).and_return @fluffer
      Mallow::Fluffer.build {}.should == @fluffer
    end
  end

end

