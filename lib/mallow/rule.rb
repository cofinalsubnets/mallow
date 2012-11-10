module Mallow
  class Rule
    attr_accessor :conditions, :actions
    Result = Class.new Struct.new :success, :value

    def initialize(conditions = [], actions = [])
      @conditions, @actions = conditions, actions
    end

    def execute(elt)
      if conditions.all? {|cond| cond.call elt}
        Result.new true, actions.inject(elt) {|e, act| act.call e} 
      else
        Result.new false, elt
      end
    end

  end
end

require_relative 'rule/builder'
