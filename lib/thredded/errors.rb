# frozen_string_literal: true

module Thredded
  class Error < StandardError
  end

  module Errors
    class DatabaseEmpty < Thredded::Error
      def message
        'Seed the database with "rake db:seed".'
      end
    end

    class LoginRequired < Thredded::Error
      def message
        'Für diese Aktion musst du eingeloggt sein!'
      end
    end

    class UserNotFound < Thredded::Error
      def message
        'Dieser User konnte nicht gefunden werden!'
      end
    end

    class UserDetailsNotFound < Thredded::Error
      def message
        'Die User Details konnten nicht gefunden werden!'
      end
    end

    class PrivateTopicNotFound < Thredded::Error
      def message
        'Die gewünschte Nachricht konnte nicht gefunden werden!'
      end
    end

    class PrivatePostNotFound < Thredded::Error
      def message
        'Die gewünschte Nachricht konnte nicht gefunden werden!'
      end
    end

    class TopicNotFound < Thredded::Error
      def message
        'Das gewünschte Thema konnte nicht gefunden werden!'
      end
    end

    class PostNotFound < Thredded::Error
      def message
        'Die gewünschte Nachricht konnte nicht gefunden werden!'
      end
    end

    class MessageboardNotFound < Thredded::Error
      def message
        'Das Subforum konnte nicht gefunden werden!'
      end
    end

    class MessageboardReadDenied < Thredded::Error
      def message
        'Tut uns Leid - leider hast du hier keinen Zugriff!'
      end
    end

    class MessageboardCreateDenied < Thredded::Error
      def message
        'Tut uns Leid - leider darfst du kein Subforum erstellen!'
      end
    end

    class TopicCreateDenied < Thredded::Error
      def message
        'Tut uns Leid - leider darfst du kein Thema erstellen!'
      end
    end

    class PrivateTopicCreateDenied < Thredded::Error
      def message
        'Tut uns Leid - leider kannst du keine Privatnachricht erstellen!'
      end
    end

    class CategoryNotFound < Thredded::Error
      def message
        'Die Kategorie konnte nicht gefunden werden!'
      end
    end

    class MessageboardGroupNotFound < Thredded::Error
      def message
        'Die Forumsgruppe konnte nicht gefunden werden!'
      end
    end

    class TopicSubclassNotFound < Thredded::Error
      def message
        'Ungültiger Topic-Typ!'
      end
    end
  end
end
