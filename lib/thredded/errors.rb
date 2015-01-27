module Thredded
  class Error < StandardError
  end

  module Errors
    class UserNotFound < Thredded::Error
      def message
        'This user could not be found. Is their name misspelled?'
      end
    end

    class PrivateTopicNotFound < Thredded::Error
      def message
        'This private topic does not exist.'
      end
    end

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

    class MessageboardReadDenied < Thredded::Error
      def message
        'You are not authorized access to this messageboard.'
      end
    end

    class TopicCreateDenied < Thredded::Error
      def message
        'You are not authorized to post in this messageboard.'
      end
    end

    class PrivateTopicCreateDenied < TopicCreateDenied
    end

    class EmptySearchResults < Thredded::Error
      def initialize(query)
        @query = query
      end

      def message
        "There are no results for your search - '#{@query}'"
      end
    end
  end
end
