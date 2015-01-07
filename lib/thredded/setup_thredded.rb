module Thredded
  class SetupThredded
    def matches?(_)
      Thredded::Messageboard.all.empty?
    end
  end
end
