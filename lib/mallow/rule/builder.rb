class Mallow::Rule::Builder
  attr_reader :rules, :context

  def self.build
    builder = new
    yield builder
    builder.rules
  end

  def initialize
    @rules, @context = [ Mallow::Rule.new ], :conditions
  end

  # CONDITIONS

  def where(&blk)
    self.context = :conditions
    append blk
  end

  def size(n)
    where { |elt| elt.respond_to?(:size) and elt.size == n }
  end

  def a(thing)
    where { |elt| elt.is_a? thing }
  end

  def anything
    where { true }
  end

  def tuple(n)
    an(Array).size(n)
  end

  # ACTIONS

  def to(&blk)
    self.context = :actions
    append blk
  end

  def and_hashify_with_keys(*keys)
    to { |elt| Hash[ keys.zip elt ] }
  end

  def and_hashify_with_values(*vals)
    to { |elt| Hash[ elt.zip vals ] }
  end

  def and_send(msg, obj, splat = true)
    to { |elt| splat ? obj.send(msg, *elt) : obj.send(msg, elt) }
  end

  def and_instantiate(obj, splat = true)
    and_send :new, obj, splat
  end

  def and(&blk)
    append blk
  end

  private

  def append(_proc)
    @rules.last.send(@context).push _proc
    self
  end

  def context=(new_context)
    if @context == :actions and new_context == :conditions
      @rules << Mallow::Rule.new
    end
    @context = new_context
  end

  alias an a
  alias * anything
  alias and_hashify_with and_hashify_with_keys
end

