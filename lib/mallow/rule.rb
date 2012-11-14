module Mallow
  class Rule < Struct.new(:conditions, :actions)
    Result = Class.new Struct.new :success, :value

    def initialize
      self.conditions, self.actions = [], []
    end

    def call(elt)
      if conditions.all? {|cond| cond[elt]}
        Result.new true, actions.inject(elt) {|e, act| act[e]}
      else
        Result.new false, elt
      end
    end
    alias [] call

  end
end

require_relative 'rule/builder'
