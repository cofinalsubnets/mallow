module Mallow
  VERSION = '0.1.5'
  class DeserializationException < StandardError; end

  class Core < Struct.new :rules
    def self.build(&b); new(DSL.build &b)     end
    def fluff(es);      es.map {|e| fluff1 e} end

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

    def a(c);     where {|e| e.is_a? c}                   end
    def *;        where {true}                            end
    def tuple(n); a(Array).size(n)                        end
    def and(&b);  _append(b)                              end
    def size(n);  where {|e| e.size==n rescue false}      end
    def to_new(o,s=false); and_send(:new,o,s)             end
    def to_hash_with_keys(*ks);   to {|e| Hash[ks.zip e]} end
    def to_hash_with_values(*vs); to {|e| Hash[e.zip vs]} end

    alias an a
    alias anything *
    alias to_hash_with to_hash_with_keys

    private
    def _append(_proc)
      @rules.last.send(@context).push _proc
      self
    end

    def _set_c(nc)
      @rules << Rule.new if @context == :actions && nc == :conditions
      @context = nc
    end
  end # DSL
  def self.+@(&b); Core.build(&b) end
end

