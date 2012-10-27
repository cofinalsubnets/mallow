require 'spec_helper'

describe Mallow::Rule::Builder do

  before do
    @builder = Mallow::Rule::Builder.new
    @proc = proc { true }
  end

  it 'has one rule by default' do
    @builder.rules.size.should == 1
  end

  describe '#new_rule' do
    it 'appends a new rule' do
      @builder.new_rule.rules.size.should == 2
    end
    it 'sets the context to :conditions' do
      @builder.context = :actions
      @builder.new_rule.context.should == :conditions
    end
    context 'when called with a proc argument' do
      it 'appends a condition to the new rule' do
        @builder.new_rule @proc
        conditions = @builder.rules.last.conditions
        conditions.size.should == 1
        conditions.first.should == @proc
      end
    end
  end

  describe '#and' do
    [:actions, :conditions].each do |param|
      context "when @context == :#{param}" do
        before { @builder.instance_variable_set :@context, param }

        it "appends a new #{param.to_s.chop} to the current rule" do
          @builder.and &@proc
          @builder.rules.last.send(@builder.context).last.should == @proc
        end
      end
    end
  end

  describe '#to' do
    it "sets the context to :actions" do
      @builder.instance_variable_set :@context, :conditions
      @builder.to &@proc
      @builder.context.should == :actions
    end
    it "appends an action to the current rule" do
      num = @builder.rules.size
      @builder.to &@proc
      @builder.rules.size.should == num
    end
  end

  describe '#a' do
    it "appends a class-matching condition" do
      verify_success @builder.a(Array).rules.last,
       [1,2,3] => true,
       123     => false
    end
  end

  describe '#anything' do
    it "appends a wildcard condition" do
      rule = @builder.anything.rules.last
      [ 123, :abc, true, false, nil, { 1 => 2 }, [1,2], Class.new ].each do |thing|
        verify_success rule, thing => true
      end
    end
  end

  describe '#tuple' do
    it "appends a size-matching condition and an array-matching condition" do
      verify_success @builder.tuple(2).rules.last,
        [1]            => false,
        [1,2]          => true,
        {a: :b, c: :d} => false,
        12345          => false
    end
  end

  describe '#size' do
    it "appends a size-matching condition" do
      verify_success @builder.size(1).rules.last,
        [1]     => true,
        [1,2]   => false,
        {a: :b} => true,
        12345   => false
    end
  end

  describe '#where' do
    it 'appends an arbitrary condition' do
      p = proc {12345}
      @builder.where &p
      @builder.rules.last.conditions.last.should == p
    end
    context 'when @context == :actions' do
      before { @builder.instance_variable_set :@context, :actions }
      it 'appends a new rule' do
        count = @builder.rules.size
        @builder.where &@proc
        @builder.rules.size.should == count + 1
      end
      it 'switches the context to :conditions' do
        @builder.where &@proc
        @builder.context.should == :conditions
      end
    end
    context 'when @context == :conditions' do
      before { @builder.instance_variable_set :@context, :conditions }
      it 'does not append a new rule' do
        count = @builder.rules.size
        @builder.where &@proc
        @builder.rules.size.should == count
      end
      it 'preserves the context' do
        @builder.context.should == :conditions
      end
    end
  end

  describe '#and_send' do
    it "sends the supplied method to the supplied object with the matched array's elements" do
      verify_values @builder.*.and_send(:+, 1).rules.last,
        1 => 2
    end
  end

  describe '#and_hashify_with_keys' do
    it "builds a hash with keys passed as arguments and values from the matched array" do
      verify_values @builder.and_hashify_with_keys(:name, :age).rules.last,
        ['Pete', 21] => {name: 'Pete', age: 21}
    end
  end

  describe '#and_hashify_with_values' do
    it "builds a hash with values passed as arguments and keys from the matched array" do
      verify_values @builder.and_hashify_with_values(:name, :age).rules.last,
        ['Pete', 21] => {'Pete' => :name, 21 => :age}
    end
  end

  describe '#and_instantiate' do
    it "calls ::new on the supplied class with the matched array's elements" do
      verify_values @builder.*.and_instantiate(Array).rules.last,
        [1,2] => [2]
    end
  end

  describe '::build' do
    it 'instantiates a new Builder' do
      Mallow::Rule::Builder.should_receive(:new).and_return @builder
      Mallow::Rule::Builder.build {}
    end
  end

end
