module Thredded
  class Error < StandardError
  end

  module Errors
    class TopicNotFound < Thredded::Error
      def message
        'This topic does not exist.'
      end
    end

    class MessageboardNotFound < Thredded::Error
      def message
        'This messageboard does not exist.'
      end
    end
  end
end
