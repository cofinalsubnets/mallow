module Mallow
  # Rule monad(ish) encapsulating "execute the first rule whose conditions
  # pass" logic.
  class Rule < Struct.new :matcher, :transformer, :val
    class << self
      def return(v); new Matcher.new, Transformer.new, v end
    end
    # Curried proc for building procs for binding rules. If this were Haskell
    # its type signature might vaguely resemble:
    # Elt e => [e -> Bool] -> [e -> e] -> e -> Maybe (Meta e)
    Builder = ->(cs, as, e) {Rule.new cs, as, e }.curry
    # Behaves like an inverted Maybe: return self if match succeeds, otherwise
    # attempt another match.
    def bind(rule_proc); matcher === val ? self : rule_proc[val] end
    def return(val); Rule.new cs, as, val end
    def unwrap!; matcher === val ? transformer >> val : dx end
    private
    def dx
      raise DeserializationException, "No rule matches #{val}:#{val.class}"
    end
  end
  # Wrapper monad(ish) for successful matches that allows the user to
  # transparently store and access metadata across binds.
  class Meta < Hash
    attr_reader :val
    class << self
      alias return new
      # Returns a proc that calls the supplied proc on its argument, and wraps
      # the return value in a Meta if it wasn't one already.
      def proc(p); ->(e){ (e=p[e]).is_a?(Meta)? e : self.return(e) } end
    end
    def initialize(obj,md={})
      @val = obj
      merge! md
    end
    # Calls argument with the wrapped object and reverse-merges its metadata
    # into that of the return value.
    def bind(meta_proc); meta_proc[val].merge(self) {|k,o,n| o} end
  end

  # Container for rule conditions
  class Matcher < Array
    # Checks argument against all conditions; returns false if no conditions
    # are present
    def ===(e); any? and all? {|t| t[e]} end
  end
  # Container for rule actions
  class Transformer < Array
    # Threads argument through actions
    def >>(e); reduce(Meta.return(e),:bind) end
    # Wraps argument using Meta::proc
    def <<(p); super Meta.proc(p) end
    alias push <<
  end

end

