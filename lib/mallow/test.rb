module Mallow
  class << self
    # A convenience method that build and executes a Mallow::Test::Core.
    # See documentation for Mallow::Test for usage.
    def test(pp = false, &b)
      res = Test::Core.build(&b).test
      pp ? Test::PrettyPrinter[res] : res
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
    def self.cases(&b); Cases.send :include, Module.new(&b) end

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

      def test; _fluff @cases end
      def self.build(&b); DSL.build &b end
    end

    class DSL < Mallow::DSL

      def initialize
        @core, @cases = Core.new, Cases.new
        reset!
      end

      def method_missing(msg, *args, &b)
        case msg.to_s
        when /^(and|that)_(.+)$/
          respond_to?($2)? send($2, *args, &b) : super
        else
          core.cases << (_case = @cases.method msg) rescue super
          rule!._this _case
        end
      end

      def where(&b);  super {|e| preproc(b)[e.call] } end
      def _this(o);   _where {|e|e==o}    end
      def _where(&b); push b, :conditions end

      def raises(x=nil)
        _where {
          begin
            call
            false
          rescue x => e
            true
          rescue   => e
            x ? raise(e) : true
          end
        }
      end

      alias is      this
      alias returns this
      alias that_is this

      alias is_such_that where
      alias such_that    where
      alias and          where

      alias raises_an           raises
      alias raises_a            raises
      alias raises_an_exception raises

      alias is_a       a
      alias is_an      a
      alias returns_a  a
      alias returns_an a

    end
  end
end

