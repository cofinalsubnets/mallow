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
  string = "[[1,2],[3,4,5],{hay : bro}]" 

  fluffer = Mallow.fluff do |match|
    match.tuple( 3 ).to { |a,b,c| a + b * c }
    match.an( Array ).where { |a| a.last == 2 }.and_instantiate( Vector )
    match.a( Hash ).and_send( HeyGoodBuddy, :heres_a_hash )
  end

  fluffer.parse( string ) #=> [#<Vector ...>, 23, 'thx 4 the hash']
```

Mallow can also be used to fluff up lower-level data structures rather than strings:

```ruby
  fluffer.fluff [[1,2,9]] #=> [19]
  fluffer.fluff_one [1,2,9] #=> 19
```

## Configuration ##

Mallow has several configuration options accessible through Mallow::config. Options include:

- :parser: the parser to use when fed strings through Mallow::Fluffer#parse. Default is Psych.
- :parser_msg: the message to send to the parser to induce it to transform a serialized string into Ruby data structures. For Psych, e.g., this is :load; for JSON, it is :parse.
- :strip_singlets?: in the even that a rule contains only one action (which will be the case in most straightforward use cases), return the actions's return value as a bare object, rather than a singleton array. Default is true.
- :splat_arrays?: when specifying actions with convenience methods like #and_instantiate, the a matching element is an array, pass its elements as individual arguments to the method called by the action? Default is true.
- :raise_on_fail?: raise an exception if an element fails to match any rules? Default is true.
- :pass_failures?: if not raise_on_fail?, pass unmatched elements through into the results unaltered? Default is false.
- :fail_replace: if not raise_on_fail? and not pass_failures?, what to replace unmatched elements with? Default is Mallow::Nothing; nil might be another sensible option.

All options can be overridden locally by passing a hash of options to Mallow::fluff or Mallow::Fluffer::build (the former is just a convenience method for accessing the latter).
