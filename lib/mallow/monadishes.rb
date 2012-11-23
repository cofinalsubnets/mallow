module Mallow
  # Rule monad(ish) encapsulating "execute the first rule whose conditions
  # pass" logic.
  class Rule < Struct.new :cs, :as, :val
    class << self
      def return(v); new [], [], v end
    end
    # Curried proc for building procs for binding rules. If this were Haskell
    # its type signature might vaguely resemble:
    # Elt e => [e -> Bool] -> [e -> e] -> e -> Maybe (Meta e)
    Builder = ->(cs, as, e) { Rule.new cs, as.map {|p| Meta.proc p}, e }.curry
    # Behaves like an inverted Maybe: return self if match succeeds, otherwise
    # attempt another match.
    def bind(rule_proc); pass?? self : rule_proc[val] end
    def return(val); Rule.new cs, as, val end
    def unwrap!; pass?? go : dx end
    private
    def pass?; cs.any? && cs.all?{|c| c[val]} end
    def go; as.reduce(Meta.return(val),:bind) end
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
end

