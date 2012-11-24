Mallow::Test.cases {
  def control_case_1; 99 end
  def DocTest1; 4 + 5 end
  def DocTest2; 'test'.upcase end
  def DocTest3; 1/0  end
  def doc_test
    Mallow.test { |that|
      that.DocTest1.returns_a(Fixnum).such_that {self < 100}
      that.DocTest2.returns 'TeST'
      that.DocTest3.returns_a Numeric
    }
  end

  def mallow_case_1
    mallow = Mallow.fluff do |match|
      match.a_string.to_upcase
      match.a_tuple(3).to {|a,b,c| a+b+c}
      match.a_fixnum.to {self*2}
    end
    data = [
      99,
      'asdf',
      'qwer',
      [5,5,5],
      47,
      %w{cool story bro}
    ]
    mallow.fluff data
  end
}

Mallow.test(true) {|that|
  that.control_case_1.is 99

  that.doc_test.returns_an(Array).of_size(3).such_that do |v|
    [ v[0] == [:DocTest1, true],
      v[1] == [:DocTest2, false],
      v[2][0] == :DocTest3,
      v[2][1].is_a?(ZeroDivisionError),
    ].all?
  end

  that.mallow_case_1.returns [
    198,
    'ASDF',
    'QWER',
    15,
    94,
    'coolstorybro'
  ]
}

