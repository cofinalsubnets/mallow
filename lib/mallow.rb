require_relative 'mallow/rule'
require_relative 'mallow/fluffer'
require_relative 'mallow/parser'
require_relative 'mallow/version'

module Mallow

  def self.fluffer(&blk)
    Fluffer.build &blk
  end

  def self.parser(prsr, &blk)
    Parser.new prsr, fluffer(&blk)
  end

end

