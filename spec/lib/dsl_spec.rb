require 'spec_helper'

describe Mallow::DSL do

  before do
    @dsl = Mallow::DSL.new
    @proc = proc { true }
  end

  it 'has one rule by default' do
    @dsl.rules.size.should == 1
  end

  describe '#and' do
    [:actions, :conditions].each do |param|
      context "when @context == :#{param}" do
        before { @dsl.instance_variable_set :@context, param }

        it "appends a new #{param.to_s.chop} to the current rule" do
          @dsl.and &@proc
          @dsl.rules.last.send(param).last.should == @proc
        end
      end
    end
  end

  describe '#to' do
    it "sets the context to :actions" do
      @dsl.instance_variable_set :@context, :conditions
      @dsl.to &@proc
      @dsl.context.should == :actions
    end
    it "appends an action to the current rule" do
      num = @dsl.rules.size
      @dsl.to &@proc
      @dsl.rules.size.should == num
    end
  end

  describe '#a' do
    it "appends a class-matching condition" do
      verify_success @dsl.a(Array).rules.last,
       [1,2,3] => true,
       123     => false
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
      verify_success @dsl.tuple(2).rules.last,
        [1]            => false,
        [1,2]          => true,
        {a: :b, c: :d} => false,
        12345          => false
    end
  end

  describe '#size' do
    it "appends a size-matching condition" do
      verify_success @dsl.size(1).rules.last,
        [1]     => true,
        [1,2]   => false,
        {a: :b} => true,
        12345   => false
    end
  end

  describe '#where' do
    it 'appends an arbitrary condition' do
      p = proc {12345}
      @dsl.where &p
      @dsl.rules.last.conditions.last.should == p
    end
    context 'when @context == :actions' do
      before { @dsl.instance_variable_set :@context, :actions }
      it 'appends a new rule' do
        count = @dsl.rules.size
        @dsl.where &@proc
        @dsl.rules.size.should == count + 1
      end
      it 'switches the context to :conditions' do
        @dsl.where &@proc
        @dsl.context.should == :conditions
      end
    end
    context 'when @context == :conditions' do
      before { @dsl.instance_variable_set :@context, :conditions }
      it 'does not append a new rule' do
        count = @dsl.rules.size
        @dsl.where &@proc
        @dsl.rules.size.should == count
      end
      it 'preserves the context' do
        @dsl.context.should == :conditions
      end
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

