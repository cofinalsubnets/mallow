$LOAD_PATH << File.dirname(__FILE__)
require 'mallow/version'
require 'mallow/monads'
require 'mallow/dsl'
module Mallow
  class MatchException < StandardError; end
  class Core < Array
    def fluff(es);  _fluff(es).map &:val                  end
    def fluff1(e);  _fluff1(e).val                        end
    def _fluff(es); es.map {|e| _fluff1 e}                end
    def _fluff1(e); reduce(Rule.return(e),:bind).unwrap!  end
  end
  # see DSL#build_core
  def self.build(&b); DSL.build_core &b end
end

