module Mallow
  class << self
    # A convenience method that build and executes a Mallow::Test::Core.
    # See documentation for Mallow::Test for usage.
    def test(pp = false, &b)
      res = Test::Core.build(&b).test!
      pp ? Test.pp(res) : res
    end
  end
  # = A basic testing library implemented with Mallow.
  # ---
  # Test cases are instance methods on Mallow::Test::Cases, and the expected
  # properties of their return values are enumerated using a slightly
  # modified Mallow::DSL.
  # 
  #  Mallow::Test::Cases {
  #    def test1; 4 + 5 end
  #    def test2; 'test'.upcase end
  #    def test3; 1/0 end
  #  }
  #
  #  Mallow::Test { |that|
  #    that.Test1.is 45
  #    that.Test2.returns 'TEST'
  #    that.Test3.returns_a Numeric
  #  } #=> [[:Test1, false], [:Test2, true], [:Test3, #<ZeroDivisionError>]]
  #
  module Test
    autoload :PrettyPrinter, 'mallow/test/pretty_printer'

    # Namespace for test cases; see documentation for Mallow::Test
    class Cases; end

    class << self
      def cases(&b)
        Cases.send :include, Module.new(&b)
      end

      def pp(res)
        PrettyPrinter.print res
      end
    end

    class Core < Mallow::Core
      attr_accessor :cases
      def initialize(*args)
        @cases = []
        super
      end

      def _fluff1(e)
        obj, name = e
        begin
          super(obj)
          [name, true]
        rescue DeserializationException => e
          [name, false]
        rescue => e
          [name, e]
        end
      end

      def test!; _fluff @cases end
      def self.build(&b); DSL.build &b end
    end

    class DSL < Mallow::DSL

      def initialize
        @core = Core.new
        @cases = Cases.new
        reset!
      end

      def method_missing(msg, *args)
        core.cases << [(_case = @cases.method(msg)), msg] rescue super
        rule!.this _case
      end

      def returns(v=nil)
        block_given??
          where {|p| yield p.call} :
          where {call == v}
      end
      def returns_a(v); where {call === v} end

      alias is this
      alias is_a a
      alias is_an a
      alias returns_an returns_a
    end
  end
end

