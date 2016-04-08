module Thredded
  class Error < StandardError
  end

  module Errors
    class DatabaseEmpty < Thredded::Error
      def message
        'Seed the database with "rake dev:seed".'
      end
    end

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

    class MessageboardCreateDenied < Thredded::Error
      def message
        'You are not authorized to create a new messageboard.'
      end
    end

    class TopicCreateDenied < Thredded::Error
      def message
        'You are not authorized to post in this messageboard.'
      end
    end

    class PrivateTopicCreateDenied < TopicCreateDenied
    end
  end
end
