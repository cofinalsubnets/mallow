module Mallow
  class Rule
    class Result
      attr_reader :success, :value
      def initialize(success, value)
        @success, @value = success, value
      end
    end
  end
end
