module Mallow
  VERSION = '0.0.2'
  class DeserializationException < StandardError; end

  class << self
    def fluff(&b); Core.build(&b) end
  end

  class Core < Struct.new :rules
    def self.build(&b); new(DSL.build &b) end
    def fluff(es); es.map {|e| fluff1 e}  end
    def fluff1(e)
      rules.each {|r| res=r[e]; return res[1] if res[0]}
      raise DeserializationException.new "No rule matches #{e}"
    end
  end # Core

  class Rule < Struct.new :conditions, :actions
    def initialize
      self.conditions, self.actions = [], []
    end
    def call(elt)
      [(r=conditions.all?{|c| c[elt]}), r ? actions.inject(elt){|e,a| a[e]} : elt]
    end
    alias [] call
  end # Rule

  class Meta < Hash
    attr_accessor :object
    def initialize(o,h={})
      @object = o
      merge! h
    end
    alias -@ object
  end # Meta

  class DSL
    attr_reader :rules, :context
    def self.build
      yield (dsl = new)
      dsl.rules
    end

    def initialize
      @rules, @context = [Rule.new], :conditions
    end

    def where(&b)
      _set_c :conditions
      _append b
    end

    def to(&b)
      _set_c :actions
      _append b
    end

    def and_send(msg, obj, splat = false)
      to {|e| splat ? obj.send(msg, *e) : obj.send(msg, e)}
    end

    def with_metadata(d={})
      to {|e| e.is_a?(Meta) ? e.merge(d) : Meta.new(e, d)}
    end

    def a(c);     where {|e| e.is_a? c} end
    def *;        where {true}          end
    def tuple(n); a(Array).size(n)      end
    def and(&b);  _append(b)            end
    def size(n);     where {|e| e.size==n     rescue false}   end
    def with_key(k); where {|e| e.has_key?(k) rescue false}   end
    def and_make(o,s=false);          and_send(:new,o,s)      end
    def and_hashify_with_keys(*ks);   to {|e| Hash[ks.zip e]} end
    def and_hashify_with_values(*vs); to {|e| Hash[e.zip vs]} end

    alias an a
    alias md with_metadata
    alias anything *
    alias and_hashify_with and_hashify_with_keys
    alias and_make_a and_make
    alias and_make_an and_make
    alias a_tuple tuple
    alias of_size size

    private
    def _append(p)
      @rules.last.send(@context) << _md_bind(p)
      self
    end

    def _set_c(nc)
      @rules << Rule.new if @context == :actions && nc == :conditions
      @context = nc
    end

    def _md_bind(p)
      proc do |e|
        o, md = e.is_a?(Meta) ? [-e,e] : [e]
        md ? (md.object=p[o];md) : p[o]
      end
    end
  end # DSL
end

