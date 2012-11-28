module Mallow
  # Rule monad(ish) encapsulating "execute the first rule whose conditions
  # pass" logic.
  class Rule < Struct.new :matcher, :transformer, :val
    def self.return(v); new Matcher.new, Transformer.new, v end
    # Curried proc for building procs for binding rules. If this were Haskell
    # its type signature might vaguely resemble:
    # Elt e => [e -> Bool] -> [e -> e] -> e -> Maybe (Meta e)
    Builder = ->(cs, as, e) {Rule.new cs, as, e }.curry
    # Behaves like an inverted Maybe: return self if match succeeds, otherwise
    # attempt another match.
    def bind(rule_proc); matcher === val ? self : rule_proc[val] end
    def return(val); Rule.new matcher, transformer, val end
    def unwrap!; matcher === val ? transformer >> val : dx end
    private
    def dx
      raise MatchException, "No rule matches #{val}:#{val.class}"
    end
  end
  # Wrapper monad(ish) for successful matches that allows the user to
  # transparently store and access metadata across binds.
  class Meta < Hash
    attr_reader :val
    # Curried proc that takes a proc and an object, calls the proc with the
    # object, and wraps the return value in a Meta if it wasn't one already.
    Builder = ->(p,e) { Meta === (e=p[e]) ? e : Meta.return(e) }.curry
    def initialize(obj,md={})
      @val = obj
      merge! md
    end
    # Calls argument with the wrapped object and reverse-merges its metadata
    # into that of the return value.
    def bind(meta_proc); meta_proc[val].merge(self) {|k,o,n| o} end
    class << self; alias return new end
  end

  # Container for rule conditions
  class Matcher < Array
    def initialize; @memo={} end
    # Checks argument against all conditions; returns false if no conditions
    # are present
    def ===(e); @memo[e] ||= (any? and all? {|t| t[e]}) end
  end
  # Container for rule actions
  class Transformer < Array
    # Threads argument through actions
    def >>(e); reduce(Meta.return(e),:bind) end
    # Wraps argument using Meta::proc
    def <<(p); super Meta::Builder[p] end
  end
end

