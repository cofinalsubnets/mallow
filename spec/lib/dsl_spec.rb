require 'spec_helper'

describe Mallow::DSL do

  before do
    @dsl = Mallow::DSL.new
    @proc = proc { true }
  end

  it 'starts with no rules' do
    @dsl.rules.should have(0).things
  end

  describe '#to' do
    it "appends an action to the current rule" do
      @dsl.to &@proc
      @dsl.send(:in_conds?).should be_false
      @dsl.queue.should have(1).thing
    end
  end

  describe '#a' do
    it "appends a class-matching condition" do
      cond = @dsl.a(Array).queue.last
      cond.call([1,2,3]).should be_true
      cond.call(123).should be_false
    end
  end

  describe '#*' do
    it "appends a wildcard condition" do
      rule = @dsl.*.queue.last
      [ 123, :abc, true, false, nil, { 1 => 2 }, [1,2], Class.new ].each do |thing|
        rule[thing].should be_true
      end
    end
  end

  describe '#size' do
    it "appends a size-matching condition" do
      cond = @dsl.size(1).queue.last
      [[1], {a: :b}].each do |e|
        cond[e].should be_true
      end
      [[1,2], 12345].each do |e|
        cond[e].should be_false
      end
    end
  end

  describe '#where' do
    it 'appends an arbitrary condition' do
      @dsl.where {12345}.queue.last.call.should == 12345
    end
  end

  describe '#and_send' do
    it "sends the supplied method to the supplied object with the matched array's elements" do
      @dsl.and_send(:+, 1).queue.last[1].should == 2
    end
  end

  describe '#and_hashify_with_keys' do
    it "builds a hash with keys passed as arguments and values from the matched array" do
      @dsl.and_hashify_with_keys(:name, :age).queue.last[
        ['Pete', 21]
      ].should == {name: 'Pete', age: 21}
    end
  end

  describe '#and_hashify_with_values' do
    it "builds a hash with values passed as arguments and keys from the matched array" do
      @dsl.and_hashify_with_values(:name, :age).queue.last[
        ['Pete', 21]
      ].should == {'Pete' => :name, 21 => :age}
    end
  end

  describe '#and_make' do
    it "calls ::new on the supplied class with the matched array's elements" do
      @dsl.and_make(Array, true).queue.last[[1,2]].should == [2]
    end
  end

end

