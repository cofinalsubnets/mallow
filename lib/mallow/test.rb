# = A testing library for Mallow, by Mallow
# ---
# Test cases are instance methods on a class defined in the Mallow::Test
# namespace, (defaults to Mallow::Test::Cases) and properties of their return
# values are enumerated using a slightly modified subclass of Mallow::DSL.
# 
#  class Mallow::Test::Cases
#    def test1; 4 + 5 end
#    def test2; 'test'.upcase end
#    def test3; 1/0 end
#  end
#
#  Mallow::Test.ns { |that|
#    that.test1.returns_a(Fixnum).such_that {self < 100}
#    that.test2.returns 'TeST'
#    that.test3.returns_a Numeric
#  } #=> [[:test1, true], [:test2, false], [:test3, #<ZeroDivisionError>], [:test1, true]]
# TODO:
# * some kind of helper for concurrent expectation chains
module Mallow
  module Test
    autoload :PrettyPrinter, 'mallow/test/pretty_printer'
    # Namespace for test cases; see documentation for Mallow::Test
    class Cases; end
    class << self
      # A convenience method that builds and executes a Mallow::Test::Core
      # in the given namespace (defaults to Cases). See documentation for
      # Mallow::Test for more on usage.
      def ns(ns=self::Cases, &b)
        ns=const_get(ns) if ns.is_a? Symbol
        Mallow::Test::Core.build(ns, &b).test
      end
      # A convenience methods that calls ::ns and passes the output to a
      # pretty printer.
      def pp(ns=self::Cases, &b)
        PrettyPrinter[ self.ns ns,&b ]
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

      def test; _fluff @cases end
      def self.build(ns, &b); DSL.build ns, &b end
    end

    class DSL < Mallow::DSL

      def self.build(ns)
        yield(dsl = new(ns))
        dsl.finish!
      end

      def initialize(ns)
        @core, @cases = Core.new, ns.new
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

