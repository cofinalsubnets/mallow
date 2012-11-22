module Mallow
  module Monadish

    def self.included(c)
      c.extend Module.new {def bind!(e,a); a.reduce(self.return(e), :bind) end}
    end
    def return(o); self.class.return o end

    module Proc
      class << self
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

    class Rule < Struct.new :val
      include Monadish
      def >>(e)  self.val = e.val; self end
      def bind(p)
        val.is_a?(Meta)?
          self :
          self >> p[val]
      end
      def self.return(e) (r=new).val=e; r end
    end


    class Meta < Hash
      attr_reader :val
      include Monadish
      def initialize(o,h={})
        @val = o
        merge! h
      end
      def >>(o); @val=o.val; merge o end
      def bind(p); self >> p[val]      end
      class << self; alias return new end
    end

  end

end

