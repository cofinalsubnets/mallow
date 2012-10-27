module Mallow
  class Fluffer
    attr_accessor :config, :rules
    DeserializationException = Class.new StandardError

    def initialize(rules, config = Mallow.config)
      @rules, @config = rules, config
    end

    def parse(str)
      fluff config[:parser].send(config[:verb], str)
    end

    def parse_one(str)
      fluff_one config[:parser].send(config[:verb], str)
    end

    def fluff(elts)
      elts.map {|elt| fluff_one elt}
    end

    def fluff_one(elt)
      rules.each do |rule|
        res = rule.execute elt
        return res.value if res.success
      end
      raise DeserializationException.new "No rule matches #{elt}"
    end

    def self.build(config = {}, &blk)
      config = Mallow.config.merge config
      new (Rule::Builder.build &blk), config
    end

  end
end
