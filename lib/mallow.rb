require_relative 'mallow/rule'
require_relative 'mallow/fluffer'
require_relative 'mallow/parser'
require_relative 'mallow/version'
module Mallow
  VERSION = '0.1.0'
  def self.fluff(&blk)
    Fluffer.build &blk
  end
end
