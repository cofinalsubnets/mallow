class RuleTests
  def initialize
    (@fmatcher = Mallow::Matcher.new)[0] = ->(e){false}
    (@pmatcher = Mallow::Matcher.new)[0] = ->(e){true}
    @fbuilder = Mallow::Rule::Builder[@fmatcher, Mallow::Transformer.new]
    @pbuilder = Mallow::Rule::Builder[@pmatcher, Mallow::Transformer.new]
  end

  def unwrapping_an_empty_rule
    Mallow::Rule.return(nil).unwrap!
  end

  def unwrapping_a_passing_rule
    @pbuilder[:value].unwrap!
  end

  def unwrapping_a_failing_rule
    @fbuilder[:value].unwrap!
  end

  def binding_a_failing_rule_in_a_passing_rule
    @fbuilder[1].bind(@pbuilder)
  end

  def binding_a_passing_rule_in_a_failing_rule
    @pbuilder[//].bind(@fbuilder)
  end

  def binding_a_passing_rule_in_a_passing_rule
    (passing_matcher = Mallow::Matcher.new)[0] = ->(e){1}
    passing_builder  = Mallow::Rule::Builder[passing_matcher, Mallow::Transformer.new]
    @pbuilder[1].bind passing_builder
  end

  def binding_a_failing_rule_in_a_failing_rule
    (failing_matcher = Mallow::Matcher.new)[0] = ->(e){nil}
    failing_builder  = Mallow::Rule::Builder[failing_matcher, Mallow::Transformer.new]
    @fbuilder[1].bind failing_builder
  end
end

Graham.pp(RuleTests.new) do |that|
  that.unwrapping_an_empty_rule.raises_a Mallow::MatchException
  that.unwrapping_a_failing_rule.raises_a Mallow::MatchException
  that.unwrapping_a_passing_rule.returns_a(Mallow::Meta).such_that { val == :value }

  that.binding_a_failing_rule_in_a_passing_rule.returns_a(Mallow::Rule).such_that { matcher === val }
  that.binding_a_passing_rule_in_a_passing_rule.returns_a(Mallow::Rule).such_that { matcher === val }
  that.binding_a_passing_rule_in_a_failing_rule.returns_a(Mallow::Rule).such_that { matcher === val }
  that.binding_a_failing_rule_in_a_failing_rule.returns_a(Mallow::Rule).such_that { not matcher === val }
end

