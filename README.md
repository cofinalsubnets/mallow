# Mallow #

Mallow is a tiny data deserializer with convenient parser integration and a friendly interface for specifying inflation rules.

## Usage ##

First marshal, then Mallow!

```ruby
  data = [{:hay => :good_buddy}]

  m = Mallow.fluff do |match|
    match.a( Hash ).to {|h| "#{h.keys.first} #{h.values.first}"}
  end

  m.fluff data #=> ['hay good_buddy']
```
Mallow implements a DSL for specifying conditions and actions, with a rich vocabulary of built-in helpers:
```ruby
  Mallow.fluff { |match|
    match.a( Float ).to &:to_i
    match.a_tuple( 3 ).where {|a| a.last != 0 }.to { |a,b,c| a + b / c }
    match.a_tuple( 2 ).and_hashify_with( :name, :age ).and_make_a( Person ).and &:save!
    match.a( Hash ).of_size( 22 ).with_key( :crab_nebula ).to { EPIC_SPACE_JOURNEY }
    match.*.to { WILDCARD }
  }.fluff( data )
```

