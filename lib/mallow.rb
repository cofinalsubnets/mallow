require_relative 'mallow/version'
require_relative 'mallow/monadishes'
require_relative 'mallow/dsl'

module Mallow
  Rule = Monadish::Rule
  Meta = Monadish::Meta
  DX   = DeserializationException = Class.new StandardError

  class Core < Struct.new :rules
    def self.build(&b); new(DSL.build &b) end
    def _fluff(es); es.map {|e| _fluff1 e}  end
    def _fluff1(e)
      obj = Rule.bind!(e, rules).val
      obj.is_a?(Meta) ? obj : fail(DX, "No rule matches `#{e}:#{e.class}'")
    end
    def fluff(es); es.map  {|e| fluff1 e} end
    def fluff1(e); _fluff1(e).val end
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

