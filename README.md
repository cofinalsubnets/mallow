# Mallow #

Mallow is an engine and DSL for pattern matching and transforming Ruby objects that mildly eases the task of processing heterogeneous data sets. It is small, stateless, and strives to take simultaneous advantage of neat-o Ruby language features and functional programming techniques, while also reinventing ~~as few wheels as possible~~ ~~relatively few wheels~~ <  1 wheel / 20 LOC.

An example of Mallow's versatility is Graham, a tiny testing library powered by Mallow and used for Mallow's own unit tests.

## Papa teach me to mallow ##

To mallow it is very easy little boy. First marshal, then mallow:

```ruby
  mallow = Mallow.build do |match|
    match.a_hash.to {"#{keys.first} #{values.first}"}
  end
```
Now feed your mallow some iterable data:
```ruby
  data = [{:hay => :good_buddy}]
  mallow.fluff data #=> ["hay good_buddy"]
```
Mallow's DSL has a moderately rich vocabulary of built-in helpers (with complementary method_missing magic if that's yr thing):
```ruby
  Mallow.build { |match|
    match.a(Float).to &:to_i
    match.tuple(3).where{last != 0}.to {|a,b,c| (a + b) / c}
    match.an(Array).and_hashify_with( :name, :age ).and_make_a( Person ).and &:save!
    match.a_fixnum.of_size(8).to {'8bit'}
    match.a_string.to_upcase
    match.*.to { WILDCARD }
  }.fluff( data )
```

### Metadata ###

A mallow is stateless, so it can't supply internal metadata (like index or match statistics) to rules. But that is not necessary for two reasons. First:
```ruby
  Mallow.build do |match|
    line = 0
    match.a(Fixnum).to {"Found a fixnum on line #{line+=1}"}
    match.*.to {|e| line+=1;e}
  end
```
But that is just awful, and will betray you if you forget to increment the line number or define your rules in different lexical environments.

Luckily the second reason is that this should be done as part of some kind of post-processing anyway. To aid in such an undertaking, Mallow wraps a matched element in its _own_ metadata, which can be accessed transparently at any point in the transformer chain once a match has succeeded:
```ruby
  doubler = Mallow.build do |m|
    m.a(Fixnum).^(type: Fixnum).to {|n| n*2}
    m.anything.to {nil}.^(matched: false)
  end

  data = doubler.fluff  [1,2,:moo]     #=> [2, 4, nil]
  metadata = doubler._fluff [1,2,:moo] #=> [{:type=>Fixnum}, {:type=>Fixnum}, {:matched=>false}]
  metadata.map(&:val)                  #=> [2, 4, nil]
```

### Blocks & bindings ###

When a matcher is passed a parameter-less block, Mallow evaluates that block in the context of the element running against the matcher:
```ruby
  Mallow.build {|m| m.*.to {self} }.fluff1(1) #=> 1
```
In most cases this helps to make code less verbose and more semantic without having to rely on dispatch-via-method_missing (hooray!). If you're sticking side-effecting code in these blocks, though, weird things could potentially happen unless you're careful. If you want to avoid this behaviour, just be sure to give parameters to your blocks.

