# Mallow #

Mallow is a tiny data deserializer with convenient parser integration and a friendly interface for specifying inflation rules.

## Usage ##

First marshal, then Mallow!


```ruby
  data = [{:hay => :good_buddy}]

  fluffer = Mallow::Fluffer.new do |match|
    match.a( Hash ).to {|h| "#{h.keys.first} #{h.values.first}"}
  end

  fluffer.fluff data #=> ['hay good_buddy']
```

Mallow can also wrap a parser:

```ruby
  parser = Mallow::Parser.new( proc {|str| JSON.parse str}, fluffer )

  fluffer.fluff [[1,2,9]]         #=> [<some thing>]
  parser.parse  [[1,2,9]].to_json #=> [<same thing>]
```
Mallow lets you specify your own conditions and actions and has a rich vocabulary of built-in helpers:
```ruby
  Mallow::Fluffer.new do |match|
    match.a( Float ).to &:to_i
    match.tuple( 3 ).where {|a| a.last != 0 }.to { |a,b,c| a + b / c }
    match.tuple( 2 ).and_hashify_with( :name, :age ).and_instantiate( Person ).and &:save!
    match.a( Hash ).size( 22 ).where {|h| h.has_key? :crab_nebula }.to { EPIC_SPACE_JOURNEY }
    match.*.to { WILDCARD }
  end.fluff( data )
```

