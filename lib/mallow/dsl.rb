module Mallow
  class DSL

    class Rule < Struct.new :conditions, :actions
      def initialize
        self.conditions, self.actions = [], []
      end
      def call(e)
        Monadish::Rule.return(
          conditions.all?{|c| c[e]} ?  Meta.bind!(e,actions) : e )
      end
      alias [] call
    end

    class Action < (Monadish::Proc < :Meta); end

    attr_reader :rules, :in_conds
    def self.build
      yield (dsl = new)
      dsl.rules
    end

    def initialize
      @rules, @in_conds = [Rule.new], true
    end

    def and_send(msg, obj, splat = false)
      to {|e| splat ? obj.send(msg, *e) : obj.send(msg, e)}
    end

    def with_metadata(d={})
      rule.actions<<->(e){Meta.new e, d}
      self
    end

    def tuple(n)
      a(Array).size(n) 
    end

    def and_make(o,s=false)
      and_send(:new,o,s)
    end

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
      when /^(to)_(.+)$/
        to {|e| e.send $2, *args}
      else
        super
      end
    end

    def where(&b); in_conds || ~self; push b end
    def to(&b);    in_conds && ~self; push b end
    def and(&b);                      push b end

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

    protected
    def rule; rules.last end

    def ~
      rules << Rule.new if @in_conds = !@in_conds
      self
    end

    def push(p)
      p = preproc p
      in_conds ?
        rule.conditions << p :
        rule.actions    << Action.new(&p)
      self
    end

    def preproc(p)
      p.parameters.empty? ? proc {|e| e.instance_eval &p} : p
    end
  end
end

