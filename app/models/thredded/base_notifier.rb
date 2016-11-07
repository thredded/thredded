# frozen_string_literal: true
module Thredded
  class BaseNotifier
    class NotificationsDefault
      def initialize(wants)
        @wants = wants
      end

      attr_reader :wants

      def wants?
        wants
      end
    end
  end
end
