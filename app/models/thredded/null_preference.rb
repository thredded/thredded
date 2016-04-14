# frozen_string_literal: true
module Thredded
  class NullPreference
    def notify_on_mention
      true
    end

    def notify_on_message
      true
    end
  end
end
