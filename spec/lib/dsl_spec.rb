require 'spec_helper'

describe Mallow::DSL do

  before do
    @dsl = Mallow::DSL.new
    @proc = proc { true }
  end

  it 'has one rule by default' do
    @dsl.rules.size.should == 1
  end

  describe '#to' do
    it "appends an action to the current rule" do
      rules = @dsl.rules.size
      actns = @dsl.rules.last.actions.size
      @dsl.to &@proc
      @dsl.rules.size.should == rules
      @dsl.rules.last.actions.size.should == (actns + 1)
    end
  end

  describe '#a' do
    it "appends a class-matching condition" do
      rule = @dsl.a(Array).rules.last
      rule[[1,2,3]].val.should be_an_instance_of Mallow::Meta
      rule[123].val.should == 123
    end
  end

  describe '#anything' do
    it "appends a wildcard condition" do
      rule = @dsl.anything.rules.last
      [ 123, :abc, true, false, nil, { 1 => 2 }, [1,2], Class.new ].each do |thing|
        verify_success rule, thing => true
      end
    end
  end

  describe '#tuple' do
    it "appends a size-matching condition and an array-matching condition" do
      rule = @dsl.tuple(2).rules.last
      [ [1], {a: :b, c: :d}, 12345 ].each do |e|
        rule[e].val.should == e
      end
      rule[[1,2]].val.should be_an_instance_of Mallow::Meta
    end
  end

  describe '#size' do
    it "appends a size-matching condition" do
      rule = @dsl.size(1).rules.last
      [[1], {a: :b}].each do |e|
        rule[e].val.should be_an_instance_of Mallow::Meta
      end
      [[1,2], 12345].each do |e|
        rule[e].val.should == e
      end
    end
  end

  describe '#where' do
    it 'appends an arbitrary condition' do
      @dsl.where {12345}.rules.last.conditions.last.call.should == 12345
    end
  end

  describe '#and_send' do
    it "sends the supplied method to the supplied object with the matched array's elements" do
      verify_values @dsl.*.and_send(:+, 1).rules.last,
        1 => 2
    end
  end

  describe '#and_hashify_with_keys' do
    it "builds a hash with keys passed as arguments and values from the matched array" do
      verify_values @dsl.and_hashify_with_keys(:name, :age).rules.last,
        ['Pete', 21] => {name: 'Pete', age: 21}
    end
  end

  describe '#and_hashify_with_values' do
    it "builds a hash with values passed as arguments and keys from the matched array" do
      verify_values @dsl.and_hashify_with_values(:name, :age).rules.last,
        ['Pete', 21] => {'Pete' => :name, 21 => :age}
    end
  end

  describe '#and_make' do
    it "calls ::new on the supplied class with the matched array's elements" do
      verify_values @dsl.*.and_make(Array, true).rules.last,
        [1,2] => [2]
    end
  end

end

