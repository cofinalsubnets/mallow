$LOAD_PATH << File.dirname(__FILE__)
require 'mallow/version'
require 'mallow/monads'
require 'mallow/dsl'
module Mallow
  class DeserializationException < StandardError; end
  class Core < Array
    def fluff(es);  _fluff(es).map &:val                  end
    def fluff1(e);  _fluff1(e).val                        end
    def _fluff(es); es.map {|e| _fluff1 e}                end
    def _fluff1(e); reduce(Rule.return(e),:bind).unwrap!  end
    # aka Mallow::DSL::build
    def self.build(&b); DSL.build &b end
  end
  # aka Mallow::Core::build
  def self.fluff(&b); Core.build &b end
end

