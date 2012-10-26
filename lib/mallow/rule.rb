module Mallow
  class Rule
    attr_accessor :conditions, :actions

    def initialize(conditions = [], actions = [])
      @conditions, @actions = conditions, actions
    end

    def execute(elt)
      if conditions.all? {|cond| cond.call elt}
        Result.new true, actions.map {|act| act.call elt} 
      else
        Result.new false, elt
      end
    end

    class Result
      attr_reader :success, :value
      def initialize(success, value)
        @success, @value = success, value
      end
    end

    class Builder
      attr_accessor :rules, :context

      def initialize(rules = [])
        @rules = rules
      end

      def to(&blk)
        @context = :actions
        @rules.last.actions.push blk
        self
      end

      def tuple(n)
        an(Array).size(n)
      end

      def and(&blk)
        @rules.last.send(@context).push blk
        self
      end

      def where(&blk)
        @context == :conditions ? (self.and &blk) : new_rule(blk)
      end

      def size(n)
        where {|elt| elt.respond_to?(:size) and elt.size == n}
      end

      def a(c)
        where {|elt| elt.is_a? c}
      end
      alias an a

      def anything
        where {true}
      end
      alias * anything

      def and_instantiate(obj, splat = Mallow.splat_arrays?)
        and_send obj, :new, splat
      end

      def and_send(obj, msg, splat = Mallow.splat_arrays?)
        to do |elt|
          if splat and elt.is_a? Array
            obj.send msg, *elt
          else
            obj.send msg, elt
          end
        end
      end

      def new_rule(p = nil)
        @context = :conditions
        @rules << Rule.new
        p ? (self.and &p) : self
      end

      def self.build
        builder = new.new_rule
        yield builder
        builder.rules
      end
    end
  end
end
