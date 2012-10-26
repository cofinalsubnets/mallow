require 'psych'
require_relative 'rule'
require_relative 'fluffer'
module Mallow

  @config = {
    parser: Psych,
    parser_msg: :load,
    strip_singlets?: true,
    splat_arrays?: true
  }

  def self.config
    @config
  end

  def self.method_missing(s)
    @config.has_key?(s.to_sym) ? @config[s.to_sym] : super
  end

  def self.fluff(&blk)
    Fluffer.build &blk
  end

end
