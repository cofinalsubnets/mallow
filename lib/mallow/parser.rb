class Mallow::Parser < Struct.new :parser, :fluffer
  def parse(str)
    fluffer.fluff parser.call str
  end
end

