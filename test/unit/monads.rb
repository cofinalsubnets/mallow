require 'testrocket'

# Non-exhaustive tests for adherence to monad laws

+-> {
  puts "Rule left identity"
  rule = Mallow::Rule.return 350_000_000
  f = Mallow::Rule::Builder[Mallow::Matcher.new][Mallow::Transformer.new]
  rule.bind(f) == f[rule.val]
}

+-> {
  puts "Rule right identity"
  rule = Mallow::Rule.return /thing/
  rule == rule.bind(->(v){Mallow::Rule.return v})
}

+-> {
  puts "Rule associativity"
  rule = Mallow::Rule.return %w{qqq}
  f = Mallow::Rule::Builder[Mallow::Matcher.new][Mallow::Transformer.new]
  g = Mallow::Rule::Builder[Mallow::Matcher.new][Mallow::Transformer.new]
  rule.bind(f).bind(g) == rule.bind(->(v){f[v].bind g})
}

+-> {
  puts "Meta left identity"
  meta = Mallow::Meta.return RUBY_VERSION
  f = ->(v) {Mallow::Meta.return v, test: :data}
  meta.bind(f) == f[meta.val]
}

+-> {
  puts "Meta right identity"
  meta = Mallow::Meta.return Mallow
  meta == meta.bind(->(v){Mallow::Meta.return v})
}

+-> {
  puts "Meta associativity"
  meta = Mallow::Meta.return __FILE__
  f = ->(v){Mallow::Meta.return v, Florence: 'Nightingale'}
  g = ->(v){Mallow::Meta.return v, 'Punk' => :Rock}
  meta.bind(f).bind(g) == meta.bind(->(v){f[v].bind(g)})
}
 
