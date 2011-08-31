module Bithug::LogInfo
  class ForkInfo < Model
    include LogHelper

    set :__user__, Bithug::User
    set :__fork__, Bithug::Repository
    set :__original__, Bithug::Repository

    [:user, :fork, :original].each do |m|
      define_method(m) { send("__#{m}__").first }
      define_method(:"#{m}=") do |model|
        prevent_change(:"__#{m}__")
        send("__#{m}__").add(model)
        model.forks.add(self.save)
      end
    end

    def to_s(mode = nil, options = {})
      "#{user.display mode, options} forked #{original.display mode, options}"
    end
  end
end
