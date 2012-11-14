require 'spec_helper'

describe Mallow::Rule do
  before { @rule   = Mallow::Rule.new }
  describe '#call' do
    it 'returns an instance of Mallow::Rule::Result' do
      @rule[nil].should be_an_instance_of Mallow::Rule::Result
    end

    [['succeeding', true], ['failing', false]].each do |cond, success|
      context "with #{cond} conditions" do
        before { @rule.conditions << proc { success } }
        it "returns a #{cond} result" do
          [true, false, nil, [1], 2345, {6 => 7}].each do |elt|
            @rule[elt].success.should == success
          end
        end
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
      it 'succeeds if and only if all conditions return truish' do
        verify_success @rule,
          8   => true,
          1.2 => false,
          4   => false,
          9   => false
      end
    end

    context 'with multiple actions' do
      before do
        [ proc {|a| a << 1},
          proc {|a| a << 2},
          proc {|a| a << 3}
        ].each {|a| @rule.actions << a}
      end
      context 'and succeeding conditions' do
        before { @rule.conditions << proc { true } }
        it 'threads the matched element through the actions in order' do
          verify_values @rule,
            [] => [1, 2, 3]
        end
      end
    end

  end
end

