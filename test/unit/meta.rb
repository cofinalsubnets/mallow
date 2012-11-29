class MetaTests
  def binding_behaviour_with_common_keys
    meta = Mallow::Meta.return 1, meta: :data, any: :body?
    meta.bind ->(v){Mallow::Meta.return v, meta: :data!}
  end
end

Graham.pp(MetaTests.new) do |that|
  that.binding_behaviour_with_common_keys.returns meta: :data!, any: :body?
end

