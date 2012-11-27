module Mallow
  class BasicDSL
    attr_reader :core, :actions, :conditions

    def self.build_core
      yield (dsl = new)
      dsl.finish!
    end

    def initialize
      @core = Core.new
      reset!
    end

    def where(&b); push b, :conditions end
    def to(&b);    push b, :actions    end
    def and(&b);   push b              end

    def finish!
      in_conds? ? to{self}.finish! : rule!.core
    end

    alias such_that where

    private
    def in_conds?
      actions.empty?
    end

    def rule!
      core << Rule::Builder[conditions, actions]
      reset!
    end

    def push(p, loc = in_conds? ? :conditions : :actions)
      rule! if loc == :conditions and not in_conds?
      send(loc) << preproc(p)
      self
    end

    def preproc(p)
      p.parameters.empty? ? proc {|e| e.instance_eval &p} : p
    end

    def reset!
      @conditions, @actions = Matcher.new, Transformer.new
      self
    end
  end
end
