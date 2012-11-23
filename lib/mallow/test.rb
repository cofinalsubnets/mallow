require 'mallow'
module Mallow
  def self.test(&b); Test::Core.build(&b).test! end
  module Test

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
        reset!
      end

      def method_missing(msg, *args)
        case msg.to_s
        when /^[A-Z].*/
          core.cases << [(_case = Test.const_get msg), msg]
          rule!.this _case
        else
          super
        end
      end

      def returns(v); where {call == v} end

      alias is this
    end
  end
end

