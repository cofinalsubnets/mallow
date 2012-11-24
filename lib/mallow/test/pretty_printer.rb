# A very primitive pretty printer for test output.
# TODO: replace with something better
module Mallow::Test::PrettyPrinter
  Bold  = "\x1b[1m"
  Plain = "\x1b[0m"
  Green = "\x1b[32m"
  Red   = "\x1b[31m"

  class << self
    def print(results, n = (ENV['backtrace'].to_i rescue 0))
      results.each do |name, result|
        case result
        when true
          msgs = [hi('PASS', Green), Plain+name.to_s]
        when false
          msgs = [hi('FAIL', Red),   Plain+name.to_s]
        else
          msgs = [hi('XPTN', Red),   Plain+name.to_s, result.message]
          if n > 0
            msgs << backtrace(result,n)
          end
        end
        (Mallow::Test::Out rescue $stdout).puts msgs.join(' :: ')
      end
    end # print

    private
    def backtrace(e,n)
      "\n" << indent(e.backtrace.first(n)).join("\n")
    end

    def indent(s)
      s.is_a?(Array) ? s.map {|s| indent s} : "  #{s}"
    end

    def hi(str, color)
      Bold+color+str
    end
  end
end
