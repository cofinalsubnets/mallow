# Mallow #

Mallow is a tiny data deserializer with convenient parser integration and a friendly interface for specifying inflation rules.

## Installation ##

```shell
  gem b mallow.gemspec
  gem i mallow*gem
```
## Usage ##

First marshal, then Mallow!


```ruby
  data = [{:hay => bro}]

  fluffer = Mallow.fluff do |match|
    match.a( Hash ).and_send :a_hash, GoodBuddy
  end

  fluffer.fluff data #=> ['hay thx for the hash']
```

Mallow can also wrap a parser:

```ruby
  fluffer.fluff [[1,2,9]]         #=> [<some thing>]
  fluffer.parse [[1,2,9]].to_json #=> [<same thing>]
```
Mallow lets you specify your own conditions and actions and has a rich vocabulary of built-in helpers:
```ruby
  Mallow.fluff do |match|
    match.a( Float ).to &:to_i
    match.tuple( 3 ).where {|a| a.last != 0 }.to { |a,b,c| a + b / c }
    match.tuple( 2 ).and_hashify_with( :name, :age ).and_instantiate( Person ).and &:save
    match.a( Hash ).size(22).where {|h| h.has_key? :crab_nebula }.to { EPIC_SPACE_JOURNEY }
    match.*.to { AHAHA_WILDCARD }
  end.parse ...
```

## Configuration ##

Mallow's config hash contains the following options:

- :parser: the parser to use when fed strings through Mallow::Fluffer#parse. Default is Psych.
- :verb: the message to send to the parser to induce it to transform a serialized string into Ruby data structures. For Psych, e.g., this is :load; for CSV, it is :parse.

Per Fluffer parsers can be specified as well:

```ruby
  Mallow.fluff(parser: CSV, verb: :parse) do |match|
    ...
  end
