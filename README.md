# Mallow #

Mallow is a little data deserializer and DSL that mildly eases the task of processing heterogeneous data sets. It is small, stateless, and strives to be cool and clever and take advantage of neat-o Ruby language features while also reinventing ~~as few wheels as possible~~ ~~relatively few wheels~~ <  1 wheel / 20 LOC.

## Papa teach me to mallow ##

To mallow is very simple little boy: first marshal, then mallow!

```ruby
  mallow = Mallow::Core.build do |match|
    match.a( Hash ).to {|h| "#{h.keys.first} #{h.values.first}"}
  end
```
Now feed your mallow some iterable data:
```ruby
  data = [{:hay => :good_buddy}]
  mallow.fluff data #=> ['hay good_buddy']
```
Mallow's DSL has a moderately rich vocabulary of built-in helpers (with complementary method_missing magic if that's yr thing):
```ruby
  Mallow.fluff { |match|
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
  Mallow.fluff do |m|
    line = 0
    m.a(Fixnum).to {"Found a fixnum on line #{line+=1}"}
    m.*.to {|e| line+=1;e}
  end
```
But that is just awful, and will betray you if you forget to increment the line number or define your rules in different lexical environments.

Luckily the second reason is that this isn't what Mallow is for, and it should be done as part of some kind of post-processing anyway. However! Mallow _does_ wrap a matched element in its own metadata, which can be accessed transparently at any point during the course of a match:
```ruby
  doubler = Mallow.fluff do |m|
    m.a(Fixnum).with_metadata(type: Fixnum).to {|n| n*2}
    m.anything.to {nil}.^(matched: false) # aliased to with_metadata
  end

  data = doubler.fluff  [1,2,:moo]     #=> [2, 4, nil]
  metadata = doubler._fluff [1,2,:moo] #=> [#<Mallow::Meta>, ...]
  metadata.map(&:obj) == data          #=> true!
```

### Of blocks & bindings ###

When a matcher is passed a parameter-less block, Mallow evaluates that block in the context of the element running against the matcher, so for example, in:
```ruby
Mallow.fluff {|m| m.to{odd?}}.fluff1(1) #=> true

```
the receiver of :odd? is 1. In most cases this isn't a problem and helps to make code less verbose and more semantic without having to rely on dispatch-via-method_missing. Hooray! If you're sticking side-effecting code in these blocks, though, weird things could potentially happen if you're not careful.

You can prevent this behaviour altogether by:
* always giving parameters to your blocks; or
* commenting out the relevant line in dsl.rb.

