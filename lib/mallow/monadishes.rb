module Mallow
  module Monadish
    def self.included(c)
      c.extend Module.new {def bindall!(e,a); a.reduce(self>>e, :lbind) end}
    end
    def lbind(p); self >= lift(p) end
  end

  class Rule < Struct.new :conditions, :actions, :obj
    include Monadish
    def initialize
      self.conditions, self.actions = [], []
    end
    def >>(e);   self.obj = e; self end
    def >=(p);   obj.is_a?(Meta)? self : p[obj] end
    def lift(r); proc {|e| r>>r[e]} end
    def [](e)
      conditions.all?{|c| c[e]} ?  Meta.bindall!(e,actions) : e
    end
    def self.>>(e) (r=new).obj=e; r end
  end

  class Meta < Hash
    attr_reader :obj
    include Monadish
    def initialize(o,h={})
      @obj = o
      merge! h
    end
    def >>(o); @obj=o.obj; merge o end
    def >=(p); self >> p[obj]      end
    def lift(p); proc {|e| Meta>>p[e]} end
    class << self; alias >> new end
  end
end

