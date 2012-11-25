class Graham::Cases
  def initialize
    @mallow1 = Mallow.fluff do |match|
      match.a_string.to_upcase
      match.a_tuple(3).to {|a,b,c| a+b+c}
      match.a_fixnum.to {self*2}
    end

    @xmallow = Mallow.fluff do |match|
      match.a(Fixnum).to {self/0}
      match.a(String).to {self/self}
      match.*.to {}
      match.a_symbol.to {UNDEFINED}
    end
  end

  def Case1
    @mallow1.fluff [ 99, 'asdf', 'qwer', [5,5,5], 47, %w{cool story bro} ]
  end

  def XCase1
    @xmallow.fluff1 1
  end
  def XCase2
    @xmallow.fluff1 ?1
  end
  def XCase3
    @xmallow.fluff1 :ok
  end
end

Graham.pp {|that|
  that.Case1.returns_an(Array).that_is [ 198, 'ASDF', 'QWER', 15, 94, 'coolstorybro' ]
  that.XCase1.raises_a ZeroDivisionError
  that.XCase2.raises_a NoMethodError
  that.XCase3.does_not_raise_an_exception
}

