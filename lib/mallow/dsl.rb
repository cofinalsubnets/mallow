module Mallow
  class DSL
    attr_reader :core, :actions, :conditions

    def self.build
      yield (dsl = new)
      dsl.finish!
    end

    def initialize
      @core = Core.new
      reset!
    end

    def where(&b); push b, :conditions end
    def to(&b);    push b, :actions    end
    def and(&b);   push b              end

    def *;           where {true}                             end
    def a(c);        where {|e| c===e}                        end
    def this(o);     where {|e| o== e}                        end
    def size(n);     where {|e| e.size==n     rescue false}   end
    def with_key(k); where {|e| e.has_key?(k) rescue false}   end

    def and_hashify_with_keys(*ks);   to {|e| Hash[ks.zip e]} end
    def and_hashify_with_values(*vs); to {|e| Hash[e.zip vs]} end
    def ^(d={});                      to {|e| Meta.new e, d } end

    def tuple(n)
      a(Array).size(n) 
    end

    def and_make(o,s=false)
      and_send(o,:new,s)
    end

    def and_send(obj, mgs, splat = false)
      to {|e| splat ? obj.send(msg, *e) : obj.send(msg, e)}
    end

    alias an a
    alias anything *
    alias and_hashify_with and_hashify_with_keys
    alias and_make_a and_make
    alias and_make_an and_make
    alias a_tuple tuple
    alias such_that where
    alias of_size size

    def finish!
      in_conds? ? to{self}.finish! : rule!.core
    end

    # Checks for three forms:
    # * an?_(<thing>) with no args
    # * (with|of)_(<msg>), which tests <match>.send(<msg>) == args.first
    # * to_(<msg>) with any args, which evals $1 and any args in the context
    #   of the match. be careful!
    def method_missing(msg, *args)
      case msg.to_s
      when /^an?_(.+)$/
        a constantize $1
      when /^(with|of)_(.+)$/
        where {|e| e.send($2) == args.first rescue false}
      when /^to_(.+)$/
        to {|e| e.instance_eval "#{$1} #{args.join ','}"}
      else
        super
      end
    end

    private
    def in_conds?
      actions.empty?
    end

    def constantize(s)
      Object.const_get s.split(?_).map(&:capitalize).join
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

