module Mallow
  class Fluffer
    attr_accessor :config, :rules
    DeserializationException = Class.new StandardError

    def initialize(rules)
      @rules = rules
    end

    def parse(str)
      fluff Mallow.parser.send(Mallow.parser_msg, str)
    end

    def parse_one(str)
      fluff_one Mallow.parser.send(Mallow.parser_msg, str)
    end

    def fluff(elts)
      elts.map {|elt| fluff_one elt}
    end

    def fluff_one(elt)
      rules.each do |rule|
        res = rule.execute elt
        return strip(res.value) if res.success
      end
      raise DeserializationException.new "No rule matches #{elt}"
    end

    def self.build(&blk)
      new(Rule::Builder.build &blk)
    end

    private

    def strip(a)
      (a.size == 1 and Mallow.strip_singlets?) ? a.first : a
    end

  end
end
