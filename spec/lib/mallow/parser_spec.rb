require 'spec_helper'

describe Mallow::Parser do

  before do
    @porn_path = "/home/feivel/porn:/usr/local/share/porn:/usr/share/porn:/tmp/porn"
    @fluffer = Mallow::Fluffer.build do |match|
      match.*.to { :nsfw }
    end
    @lambda = lambda {|str| str.split ':' }
    @parser = Mallow::Parser.new @lambda, @fluffer
  end

  describe '#parse' do

    it 'calls the parser on its argument' do
      @lambda.should_receive(:call).with(@porn_path).and_return []
      @parser.parse @porn_path
    end

    it "passes the parser's output to the fluffer" do
      @fluffer.should_receive(:fluff).with @lambda.call @porn_path
      @parser.parse @porn_path
    end
  end

end
