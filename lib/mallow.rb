module Mallow
  VERSION = '0.0.2'
  class DeserializationException < StandardError; end

  class << self
    def fluff(&b); Core.build(&b) end
    def engulf(klass, sym=:fluff, &b)
      mtd, mod = Mallow.fluff(&b), Module.new
      mod.send(:define_method, sym) {|d| mtd.fluff d}
      klass.extend mod
    end
  end

  class Core < Struct.new :rules
    def self.build(&b); new(DSL.build &b) end
    def _fluff(es); es.map {|e| _fluff1 e}  end
    def _fluff1(e)
      obj = Rule.bindall!(e, rules).obj
      obj.is_a?(Meta) ? obj : fail(DeserializationException, "No rule matches `#{e}'")
    end
    def fluff(es); es.map  {|e| fluff1 e} end
    def fluff1(e); _fluff1(e).obj end
  end # Core

  module Monadish
    def self.included(c)
      c.extend Module.new {def bindall!(e,a); a.reduce(self>>e, :lbind) end}
    end
    def lbind(p); self >= lift(p) end
  end

  class Rule < Struct.new :conditions, :actions, :obj
    include Monadish
    def initialize
      self.conditions, self.actions = [], []
    end
    def >>(e);   self.obj = e; self end
    def >=(p);   obj.is_a?(Meta)? self : p[obj] end
    def lift(r); proc {|e| r>>r[e]} end
    def [](e)
      conditions.all?{|c| c[e]} ?  Meta.bindall!(e,actions) : e
    end
    def self.>>(e) (r=new).obj=e; r end
  end # Rule

  class Meta < Hash
    attr_reader :obj
    include Monadish
    def initialize(o,h={})
      @obj = o
      merge! h
    end
    def >>(o); @obj=o.obj; merge o end
    def >=(p); self >> p[obj]      end
    def lift(p); proc {|e| Meta>>p[e]} end
    class << self; alias >> new end
  end # Meta

  class DSL
    attr_reader :rules, :in_conds
    def self.build
      yield (dsl = new)
      dsl.rules
    end

    def initialize
      @rules, @in_conds = [Rule.new], true
    end

    def where(&b); in_conds || ~self; push b end
    def to(&b);    in_conds && ~self; push b end
    def and(&b);                      push b end


    def and_send(msg, obj, splat = false)
      to {|e| splat ? obj.send(msg, *e) : obj.send(msg, e)}
    end

    def with_metadata(d={})
      rule.actions<<->(e){Meta.new e, d}
      self
    end

    def *;           where {true}                             end
    def a(c);        where {|e| e.is_a? c}                    end
    def this(o);     where {|e| e == o}                       end
    def size(n);     where {|e| e.size==n     rescue false}   end
    def with_key(k); where {|e| e.has_key?(k) rescue false}   end

    def and_hashify_with_keys(*ks);   to {|e| Hash[ks.zip e]} end
    def and_hashify_with_values(*vs); to {|e| Hash[e.zip vs]} end

    def tuple(n)
      a(Array).size(n) 
    end

    def and_make(o,s=false)
      and_send(:new,o,s)
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

    protected
    def rule; rules.last end
    def ~
      rules << Rule.new if @in_conds = !@in_conds
      self
    end
    def push(p)
      in_conds ?
        rule.conditions << p :
        rule.actions    << p
      self
    end
  end # DSL

end

