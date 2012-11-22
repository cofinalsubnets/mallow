require_relative 'mallow/version'
require_relative 'mallow/monadishes'
require_relative 'mallow/dsl'

module Mallow
  class DeserializationException < StandardError; end

  class Core < Struct.new :rules
    def self.build(&b); new(DSL.build &b) end
    def _fluff(es); es.map {|e| _fluff1 e}  end
    def _fluff1(e)
      obj = Rule.bindall!(e, rules).obj
      obj.is_a?(Meta) ? obj : fail(DeserializationException, "No rule matches `#{e}'")
    end
    def fluff(es); es.map  {|e| fluff1 e} end
    def fluff1(e); _fluff1(e).obj end
  end

  class << self
    def fluff(&b); Core.build(&b) end
    def engulf(klass, sym=:fluff, &b)
      mtd, mod = Mallow.fluff(&b), Module.new
      mod.send(:define_method, sym) {|d| mtd.fluff d}
      klass.extend mod
    end
  end
end

