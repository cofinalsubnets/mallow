module Mallow
  class DSL
    attr_reader :rules, :actions, :conditions
    class << self
      def build
        yield (dsl = new)
        dsl.finish
      end
    end

    def initialize
      @rules, @actions, @conditions = [], [], []
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

    # Checks for three forms:
    # * (a|an)_(<thing>) with no args
    # * (with|of)_(<msg>) with one arg, which tests <match>.send(<msg>) == arg
    # * to_(<msg>) with any args, which resolves to <match>.send(<msg>) *args
    def method_missing(msg, *args)
      case msg.to_s
      when /^(a|an)_(.+)$/
        args.empty??
          (a(Object.const_get $2.split(?_).map(&:capitalize).join) rescue super) :
          super
      when /^(with|of)_(.+)$/
        args.size == 1 ?
          where {|e| e.send($2) == args.first rescue false} :
          super
      when /^to_(.+)$/
        to {|e| e.send $1, *args}
      else
        super
      end
    end

    def finish
      in_conds? ? to_nil.finish : rule!.rules
    end

    private

    def in_conds?
      actions.empty?
    end

    def rule!
      rules << Rule::Builder[conditions, actions]
      @conditions, @actions = [], []
      self
    end

    def push(p, loc = in_conds? ? :conditions : :actions)
      rule! if loc == :conditions and not in_conds?
      send(loc) << preproc(p)
      self
    end

    def preproc(p)
      p.parameters.empty? ? proc {|e| e.instance_eval &p} : p
    end
  end
end

