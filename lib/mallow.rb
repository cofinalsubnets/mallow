require_relative 'mallow/rule'
require_relative 'mallow/fluffer'
require_relative 'mallow/parser'
module Mallow

  def self.fluff(&blk)
    Fluffer.build &blk
  end

end
