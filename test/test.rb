$LOAD_PATH << (path = File.dirname(__FILE__)) << "#{path}/../lib"
require 'mallow'
require 'mallow/test'

Mallow::Test.cases {
  def mtd_test_1
    99
  end
  def DocTest1; 4 + 5 end
  def DocTest2; 'test'.upcase end
  def DocTest3; 1/0  end
  def DocTest
    Mallow.test { |that|
      that.DocTest1.is 45
      that.DocTest2.returns 'TEST'
      that.DocTest3.returns_a Numeric
    }
  end

  def Test1
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
  that.DocTest.returns do |v|
    [ v[0] == [:DocTest1, false],
      v[1] == [:DocTest2, true],
      v[2][0] == :DocTest3,
      v[2][1].is_a?(ZeroDivisionError)
    ].all?
  end

  that.mtd_test_1.returns 99

  that.Test1.returns [
    198,
    'ASDF',
    'QWER',
    15,
    94,
    'coolstorybro'
  ]
}

