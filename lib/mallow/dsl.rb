module Mallow
  class DSL

    # Curried proc for building and executing rules. If this were Haskell
    # its type signature might vaguely resemble:
    # Elt e => [e -> Bool] -> [e -> Meta e] -> e -> Maybe (Meta e)
    Ruler = lambda do |cs, as, e|
      (m = Monadish::Rule.return(cs, as)).val = e; m
    end.curry

    attr_reader :rule, :rules, :queue, :in_conds
    def self.build
      yield (dsl = new)
      dsl.instance_eval {flip! unless in_conds?; rules}
    end

    def initialize
      @rule, @rules, @queue = Ruler, [], []
    end

    def and_send(msg, obj, splat = false)
      to {|e| splat ? obj.send(msg, *e) : obj.send(msg, e)}
    end

    def with_metadata(d={})
      rule.actions<<->(e){Monadish::Meta.new e, d}
      self
    end

    def tuple(n)
      a(Array).size(n) 
    end

    def and_make(o,s=false)
      and_send(:new,o,s)
    end

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

    def where(&b); in_conds? || flip!; push b end
    def to(&b);    in_conds? && flip!; push b end
    def and(&b);                       push b end

    def *;           where {true}                             end
    def a(c);        where {|e| e.is_a? c}                    end
    def this(o);     where {|e| e == o}                       end
    def size(n);     where {|e| e.size==n     rescue false}   end
    def with_key(k); where {|e| e.has_key?(k) rescue false}   end

    def and_hashify_with_keys(*ks);   to {|e| Hash[ks.zip e]} end
    def and_hashify_with_values(*vs); to {|e| Hash[e.zip vs]} end

    alias an a
    alias md with_metadata
    alias ^ with_metadata
    alias anything *
    alias and_hashify_with and_hashify_with_keys
    alias and_make_a and_make
    alias and_make_an and_make
    alias a_tuple tuple
    alias of_size size

    private

    def in_conds?
      rule == Ruler
    end

    def flip!
      if in_conds?
        @rule = rule[queue]
      else
        rules << rule[queue]
        @rule = Ruler
      end
      @queue = []
      self
    end

    def push(p)
      queue << preproc(p)
      self
    end

    def preproc(p)
      p.parameters.empty? ? proc {|e| e.instance_eval &p} : p
    end
  end
end

