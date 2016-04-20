# frozen_string_literal: true
module Thredded
  class NullUserTopicReadState
    def page
      1
    end

    def read?
      false
    end
  end
end
