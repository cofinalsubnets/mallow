class Mallow::Test::Cases
  def mallow_case_1
    mallow = Mallow.fluff do |match|
      match.a_string.to_upcase
      match.a_tuple(3).to {|a,b,c| a+b+c}
      match.a_fixnum.to {self*2}
    end
    data = [ 99, 'asdf', 'qwer', [5,5,5], 47, %w{cool story bro} ]
    mallow.fluff data
  end
end

Mallow::Test.pp {|that|
  that.mallow_case_1.returns_an(Array).that_is [ 198, 'ASDF', 'QWER', 15, 94, 'coolstorybro' ]
}

