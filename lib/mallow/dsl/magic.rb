# method_missing magic. ugly enough to earn its own module.
module Mallow::DSL::Magic
  # Checks for three forms:
  # * (a|an)_(<thing>) with no args
  # * (with|of)_(<msg>) with one arg, which tests <match>.send(<msg>) == arg
  # * to_(<msg>) with any args, which resolves to <match>.send(<msg>) *args
  def method_missing(msg, *args)
    case msg.to_s
    when /^(a|an)_(.+)$/
      args.empty??
        (a(Object.const_get $2.split(?_).map(&:capitalize).join) rescue super) :
        super
    when /^(with|of)_(.+)$/
      args.size == 1 ?
        where {|e| e.send($2) == args.first rescue false} :
        super
    when /^to_(.+)$/
      to {|e| e.send $1, *args}
    else
      super
    end
  end
end
