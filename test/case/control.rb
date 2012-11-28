class Cases
  def initialize
    @mallow = Mallow.build do |match|
      match.a(String).to{upcase}
      match.a_tuple(3).to {|a,b,c| a+b+c}
      match.a(Fixnum).to {self*2}
    end
  end

  def test_case_1
    @mallow.fluff [ 99, 'asdf', 'qwer', [5,5,5], 47, %w{cool story bro} ]
  end

end

class Exceptions
  def initialize
    @mallow = Mallow.build do |match|
      match.a(Fixnum).to {self/0}
      match.a(String).to {self/0}
    end
  end
  def division_by_zero
    @mallow.fluff1 1
  end
  def calling_a_nonexistent_method
    @mallow.fluff1 ?1
  end
  def an_unmatched_element
    @mallow.fluff1 :ok
  end

end

Graham.pp(Cases) {|that|
  that.test_case_1.returns_an(Array).that_is [ 198, 'ASDF', 'QWER', 15, 94, 'coolstorybro' ]
}

Graham.pp(Exceptions) {|that|
  that.division_by_zero.raises_a ZeroDivisionError
  that.calling_a_nonexistent_method.raises_a NoMethodError
  that.an_unmatched_element.raises_a Mallow::MatchException
}

