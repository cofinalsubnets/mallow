class MatcherTests
  def match_memoization
    i = 0
    (m=Mallow::Matcher.new) << proc {i+=1}
    5.times{m===1}
    i == 1
  end
end

Graham.pp(MatcherTests) do |that|
  that.match_memoization.is true
end
