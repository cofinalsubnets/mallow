module Mallow
  class DSL
    require 'mallow/dsl/magic'
    include Magic
    attr_reader :core, :actions, :conditions

    class << self
      def build
        yield (dsl = new)
        dsl.finish!
      end
    end

    def initialize
      @core = Core.new
      reset!
    end

    def where(&b); push b, :conditions end
    def to(&b);    push b, :actions    end
    def and(&b);   push b              end

    def *;           where {true}                             end
    def a(c);        where {|e| e.is_a? c}                    end
    def this(o);     where {|e| e == o}                       end
    def size(n);     where {|e| e.size==n     rescue false}   end
    def with_key(k); where {|e| e.has_key?(k) rescue false}   end

    def and_hashify_with_keys(*ks);   to {|e| Hash[ks.zip e]} end
    def and_hashify_with_values(*vs); to {|e| Hash[e.zip vs]} end
    def with_metadata(d={});          to {|e| Meta.new e, d}  end

    def to_nil;   to{nil}   end
    def to_true;  to{true}  end
    def to_false; to{false} end

    def tuple(n);            a(Array).size(n)   end
    def and_make(o,s=false); and_send(:new,o,s) end

    def and_send(msg, obj, splat = false)
      to {|e| splat ? obj.send(msg, *e) : obj.send(msg, e)}
    end

    alias an a
    alias md with_metadata
    alias ^ with_metadata
    alias anything *
    alias and_hashify_with and_hashify_with_keys
    alias and_make_a and_make
    alias and_make_an and_make
    alias a_tuple tuple
    alias of_size size
    alias rules core #TODO: unalias once we have some decent tests

    def finish!
      in_conds? ? to_nil.finish! : rule!.core
    end

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

