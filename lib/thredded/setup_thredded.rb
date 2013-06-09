module Thredded
  class SetupThredded
    def matches?(request)
      return Thredded::Messageboard.all.empty?
    end
  end
end
