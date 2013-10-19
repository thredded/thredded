module Thredded
  class Error < StandardError
  end

  module Errors
    class TopicNotFound < Thredded::Error; end
  end
end
