require 'spec_helper'
describe Mallow do
  describe '::fluffer' do
    it 'calls Mallow::Fluffer.build' do
      Mallow::Fluffer.should_receive :build
      Mallow.fluffer
    end
  end

  describe '::parser' do
    it 'calls Mallow::Parser.new and Mallow::fluffer' do
      p = double 'parser_proc'
      f = double 'fluffer'
      Mallow.should_receive(:fluffer).and_return f
      Mallow::Parser.should_receive(:new).with p, f
      Mallow.parser p
    end
  end
end
