module Mallow
  # Monad-like classes.
  module Monadish

    def self.included(c)
      c.extend Module.new {
        def proc(p)
          lambda {|e| self.return p[e]}
        end
      }
      c.instance_eval { alias return new }
    end
    def return(o); self.class.return o end

    # Rule monad(ish) encapsulating "execute the first rule whose conditions
    # pass" logic.
    class Rule < Struct.new :cs, :as, :val
      include Monadish
      # Returns self (if the rule passed) or calls its argument with the
      # value being matched.
      def bind(rule_proc); pass?? self : rule_proc[val] end
      def unwrap!
        pass?? meta : fail(DeserializationException, "No rule matches #{val}:#{val.class}")
      end
      private
      def pass?; cs.all?{|c| c[val]} end
      def meta
        as.map {|p| Meta.proc p}.reduce(Meta.return(val),:bind)
      end
    end

    # Wrapper monad(ish) for successful matches that allows the user to
    # transparently store and access metadata across binds.
    class Meta < Hash
      attr_reader :val
      include Monadish
      def initialize(obj,md={})
        @val = obj
        merge! md
      end
      # Returns a Meta wrapping the value wrapped by meta_proc[self.val],
      # with merged metadata.
      def bind(meta_proc);
        meta = meta_proc[val]
        @val = meta.val
        merge meta
      end
    end

  end
end

