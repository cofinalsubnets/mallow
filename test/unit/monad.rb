class Mallow::Test::Cases
  def RuleLeftIdentity
    rule = Mallow::Rule.return 350_000_000
    f = Mallow::Rule::Builder[Mallow::Matcher.new][Mallow::Transformer.new]
    rule.bind(f) == f[rule.val]
  end

  def RuleRightIdentity
    rule = Mallow::Rule.return /thing/
    rule == rule.bind(->(v){Mallow::Rule.return v})
  end

  def RuleAssociativity
    rule = Mallow::Rule.return %w{qqq}
    f = Mallow::Rule::Builder[Mallow::Matcher.new][Mallow::Transformer.new]
    g = Mallow::Rule::Builder[Mallow::Matcher.new][Mallow::Transformer.new]
    rule.bind(f).bind(g) == rule.bind(->(v){f[v].bind g})
  end

  def MetaLeftIdentity
    meta = Mallow::Meta.return RUBY_VERSION
    f = ->(v) {Mallow::Meta.return v, test: :data}
    meta.bind(f) == f[meta.val]
  end

  def MetaRightIdentity
    meta = Mallow::Meta.return Mallow
    meta == meta.bind(->(v){Mallow::Meta.return v})
  end

  def MetaAssociativity
    meta = Mallow::Meta.return __FILE__
    f = ->(v){Mallow::Meta.return v, Florence: 'Nightingale'}
    g = ->(v){Mallow::Meta.return v, 'Punk' => :Rock}
    meta.bind(f).bind(g) == meta.bind(->(v){f[v].bind(g)})
  end
end

Mallow::Test.pp {|that|
  that.RuleLeftIdentity.is  true
  that.RuleRightIdentity.is true
  that.RuleAssociativity.is true

  that.MetaLeftIdentity.is  true
  that.MetaRightIdentity.is true
  that.MetaAssociativity.is true
}

