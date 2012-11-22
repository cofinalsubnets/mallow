module Mallow
  # = Monad-like classes.
  module Monadish

    def self.included(c)
      c.extend Module.new {def bind!(e,a); a.reduce(self.return(e), :bind) end}
      c.instance_eval     {alias return new }
    end
    def return(o); self.class.return o end

    # Factory for monadishized procs
    module Proc
      class << self
        # == Factory for monadishized procs
        # Returns a new subclass of Object::Proc whose #call and #[] methods
        # wrap their return values in a new instance of the class in Monadish
        # named by m.
        def new(m)
          klass = Class.new(::Proc)
          klass.class_exec(Monadish.const_get m) {|monadish|
            @@monadish = monadish
            def call(e); @@monadish.return super end
            alias [] call
          }
          klass
        end
        alias < new
      end
    end

    # Rule monad(ish) encapsulating "execute the first rule whose conditions
    # pass" logic.
    class Rule < Struct.new :val
      include Monadish
      # Returns self (if the rule passed) or calls its argument with the
      # value being matched.
      def bind(rule_proc); val.is_a?(Meta)? self : rule_proc[val] end
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

