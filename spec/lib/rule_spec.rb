require 'spec_helper'

describe Mallow::Rule do
  before { @rule = Mallow::Rule.new }
  describe '#[]' do
    context 'when a match is made' do
      before { @rule.conditions << proc {true} }
      it "returns a Mallow::Meta" do
        @rule[nil].should be_an_instance_of Mallow::Meta
      end
    end
    context 'when no match is made' do
      before { @rule.conditions << proc {false} }
      it "returns nil" do
        @rule[nil].should be_nil
      end
    end

    context 'with multiple conditions' do
      before do
        @called = []
        [ proc {|a| @called << 1; a.is_a? Fixnum},
          proc {|a| @called << 2; a > 6},
          proc {|a| @called << 3; a.even?}
        ].each {|c| @rule.conditions << c}
      end
      it 'calls the conditions in order' do
        @rule[8]
        @called.should == [1, 2, 3]
      end
      it 'fails unless all conditions return truish' do
        @rule[9].should be_nil
      end
    end

    context 'with multiple actions' do
      before do
        @called = []
        [ proc {@called << 1},
          proc {@called << 2},
          proc {@called << 3}
        ].each {|a| @rule.actions << Mallow::Meta.fn(a)}
        @rule.conditions << proc {true}
      end
      it 'threads the matched element through the actions in order' do
        @rule[nil]
        @called.should == [1, 2, 3]
      end
    end

  end
end

