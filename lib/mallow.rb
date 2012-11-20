module Mallow
  VERSION = '0.1.5'
  DeserializationException = Class.new StandardError

  class Core < Struct.new :rules

    def fluff(es)
      es.map {|e| fluff1 e}
    end

    def fluff1(e)
      rules.each do |rule|
        res = rule[e]
        return res.value if res.success
      end
      raise DeserializationException.new "No rule matches #{e}"
    end

    def self.build(&blk)
      new RuleBuilder.build &blk
    end
  end

  class Rule < Struct.new :conditions, :actions
    Result = Class.new Struct.new(:success, :value)

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

  class RuleBuilder
    attr_reader :rules, :context

    def self.build
      builder = new
      yield builder
      builder.rules
    end

    def initialize
      @rules, @context = [Mallow::Rule.new], :conditions
    end

    def where(&blk)
      self.context = :conditions
      append blk
    end

    def size(n)
      where {|e| e.size == n rescue false}
    end

    def a(thing)
      where {|e| e.is_a? thing}
    end

    def anything
      where {true}
    end

    def tuple(n)
      an(Array).size(n)
    end

    def to(&blk)
      self.context = :actions
      append blk
    end

    def and_hashify_with_keys(*keys)
      to {|e| Hash[keys.zip e]}
    end

    def and_hashify_with_values(*vals)
      to {|e| Hash[e.zip vals]}
    end

    def and_send(msg, obj, splat = false)
      to {|e| splat ? obj.send(msg, *e) : obj.send(msg, e)}
    end

    def and_instantiate(obj, splat = false)
      and_send :new, obj, splat
    end

    def and(&blk)
      append blk
    end

    private

    def append(_proc)
      @rules.last.send(@context).push _proc
      self
    end

    def context=(new_context)
      if @context == :actions and new_context == :conditions
        @rules << Mallow::Rule.new
      end
      @context = new_context
    end

    alias an a
    alias * anything
    alias and_hashify_with and_hashify_with_keys
  end

end

