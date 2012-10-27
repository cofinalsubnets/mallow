require 'mallow/rule/result'
require 'mallow/rule/builder'

module Mallow
  class Rule
    attr_accessor :conditions, :actions

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
