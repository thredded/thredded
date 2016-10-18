# frozen_string_literal: true
module Thredded
  class NullPreference
    def notify_on_mention
      true
    end

    def notify_on_message
      true
    end

    def notify_on_followed_activity
      true
    end
  end
end
