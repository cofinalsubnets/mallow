# A very primitive pretty printer for test output.
# TODO: replace with something better
module Mallow::Test::PrettyPrinter
  class << self
    def print(results, n = (ENV['backtrace'].to_i rescue 0))
      results.each do |name, result|
        case result
        when true
          msgs = ['PASS', name]
        when false
          msgs = ['FAIL', name]
        else
          msgs = ['XPTN', name, result.message]
          if n > 0
            msgs << backtrace(result,n)
          end
        end
        puts msgs.join ' :: '
      end
    end # print

    private
    def backtrace(e,n)
      "\n" << indent(e.backtrace.first(n)).join("\n")
    end

    def indent(s)
      s.is_a?(Array) ? s.map {|s| indent s} : "  #{s}"
    end
  end
end
