require 'psych'
require 'mallow/rule'
require 'mallow/fluffer'
module Mallow

  @config = {
    parser: Psych,
    verb: :load
  }

  def self.config
    @config
  end

  def self.method_missing(s)
    @config.has_key?(s.to_sym) ? @config[s.to_sym] : super
  end

  def self.fluff(config = {}, &blk)
    Fluffer.build config, &blk
  end

end
