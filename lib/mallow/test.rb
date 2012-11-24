module Mallow
  class << self
    # A convenience method that build and executes a Mallow::Test::Core.
    # See documentation for Mallow::Test for usage.
    def test(pp = false, &b)
      res = Test::Core.build(&b).test!
      pp ? Test.pp(res) : res
    end
  end
  # = A testing library for Mallow, by Mallow
  # ---
  # Test cases are instance methods on Mallow::Test::Cases, and the expected
  # properties of their return values are enumerated using a slightly
  # modified Mallow::DSL.
  # 
  #  Mallow::Test.cases {
  #    def test1; 4 + 5 end
  #    def test2; 'test'.upcase end
  #    def test3; 1/0 end
  #  }
  #
  #  Mallow.test { |that|
  #    that.test1.returns_a(Fixnum).such_that {self < 100}
  #    that.test2.returns 'TeST'
  #    that.test3.returns_a Numeric
  #  } #=> [[:test1, true], [:test2, false], [:test3, #<ZeroDivisionError>], [:test1, true]]
  # TODO:
  # * namespaced tests
  # * some kind of helper for concurrent expectation chains
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
        [e.name] << begin
          super e
          true
        rescue DeserializationException
          false
        rescue => err
          err
        end
      end

      def test!; _fluff @cases end
      def self.build(&b); DSL.build &b end
    end

    class DSL < Mallow::DSL

      def initialize
        @core, @cases = Core.new, Cases.new
        reset!
      end

      def method_missing(msg, *args)
        core.cases << (_case = @cases.method msg) rescue super
        rule!._this _case
      end

      def where(&b)
        super {|e| preproc(b)[e.call] }
      end

      def _this(o)
        push ->(e){e==o}, :conditions
      end

      alias returns this
      alias returns_a a
      alias returns_an a
      alias is_such_that where
      alias such_that where
      alias is this
      alias is_a a
      alias is_an a

    end
  end
end

