# Mallow #

Mallow is a little data deserializer and DSL that mildly eases the task of processing heterogeneous data sets. It is small, stateless, and strives to take advantage of neat-o Ruby language features while reinventing as few wheels as possible.

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
Mallow's DSL has a moderately rich vocabulary of built-in helpers:
```ruby
  Mallow.fluff { |match|
    match.a( Float ).to &:to_i
    match.a_tuple( 3 ).where {|a| a.last != 0 }.to { |a,b,c| a + b / c }
    match.a_tuple( 2 ).and_hashify_with( :name, :age ).and_make_a( Person ).and &:save!
    match.a( Hash ).of_size( 22 ).with_key( :crab_nebula ).to { EPIC_SPACE_JOURNEY }
    match.*.to { WILDCARD }
  }.fluff( data )
```

## Metadata ##

A mallow is stateless, so it can't supply stateful metadata (like index or match statistics) to rules. But that is not necessary for two reasons. First:
```ruby
  Mallow.fluff do |m|
    line = 0
    m.a(Fixnum).to {"Found a fixnum on line #{line+=1}"}
    m.*.to {|e| line+=1;e}
  end
```
But that is just awful, and will betray you if you forget to increment the line number or define your rules in different lexical environments. Luckily the second reason is that this isn't what Mallow is for, and it should be done as part of some kind of post-processing anyway.

To aid in post-processing, Mallow provides an easy way to wrap results in metadata hashes:
```ruby
  Mallow.core do |m|
    m.a(Fixnum).md type: Fixnum
    m.*.md
  end
```
Then you can unwrap a metadata object like:
```ruby
  -metadata #=> alias for metadata.object
```

