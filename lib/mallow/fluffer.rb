class Mallow::Fluffer < Struct.new(:rules)
  DeserializationException = Class.new StandardError

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

  def self.build(&blk)
    new Mallow::Rule::Builder.build(&blk)
  end

end
