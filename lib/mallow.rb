module Mallow
  VERSION = '0.0.2'
  class DeserializationException < StandardError; end

  def self.fluff(&b); Core.build(&b) end

  class Core < Struct.new :rules, :md
    def self.build(&b); new(*DSL.build(&b)) end
    def fluff(es) -md; es.map {|e| +md; fluff1 e} end
    def fluff1(e)
      rules.each {|r| res=r[e]; return res[1] if res[0]}
      raise DeserializationException.new "No rule matches #{e}"
    end
  end # Core

  class Rule < Struct.new :conditions, :actions
    def initialize
      self.conditions, self.actions = [], []
    end
    def call(e)
      [(r=conditions.all?{|c| c[e]}), r ? actions.inject(e){|e,a| a[e]} : e]
    end
    alias [] call
  end # Rule

  class Metadata < Hash
    def -@; self[:_rec]=0  end
    def +@; self[:_rec]+=1 end
    def ln; self[:_rec]    end
    alias line ln
  end # Metadata

  class DSL
    attr_reader :rules, :context, :md
    def self.build
      yield (dsl = new), dsl.md
      [dsl.rules, dsl.md]
    end

    def initialize
      @rules, @context, @md = [Rule.new], :conditions, Metadata.new
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
    alias anything *
    alias and_hashify_with and_hashify_with_keys
    alias and_make_a and_make
    alias and_make_an and_make
    alias a_tuple tuple
    alias of_size size
    alias metadata md

    private
    def _append(p)
      @rules.last.send(@context) << p
      self
    end

    def _set_c(nc)
      @rules << Rule.new if @context == :actions && nc == :conditions
      @context = nc
    end
  end # DSL
end

