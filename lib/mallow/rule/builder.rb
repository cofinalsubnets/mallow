module Mallow
  class Rule
    class Builder
      attr_accessor :rules, :context

      def initialize
        @rules = []
        new_rule
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

      def and_instantiate(obj, splat = true)
        and_send :new, obj, splat
      end

      def and_hashify_with_keys(*keys)
        to { |elt| Hash[ keys.zip elt ] }
      end
      alias and_hashify_with and_hashify_with_keys

      def and_hashify_with_values(*vals)
        to { |elt| Hash[ elt.zip vals ] }
      end

      def and_send(msg, obj, splat = true)
        to { |elt|
          if splat and elt.is_a? Array
            obj.send msg, *elt
          else
            obj.send msg, elt
          end
        }
      end

      def new_rule(p = nil)
        @context = :conditions
        @rules << Rule.new
        p ? (self.and &p) : self
      end

      def self.build
        builder = new
        yield builder
        builder.rules
      end

    end
  end
end

