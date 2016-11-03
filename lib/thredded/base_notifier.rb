# frozen_string_literal: true

module Thredded
  class BaseNotifier
    def self.validate_notifier(notifier)
      unless notifier.respond_to?(:key) && /^[a-z_]+$/.match(notifier.key)
        fail "#{notifier.class.name} must respond to #key and must be a snake_case string"
      end
      [:human_name, :new_post, :new_private_post].each do |m|
        unless notifier.respond_to?(m)
          fail "#{notifier.class.name} must respond to ##{m}"
        end
      end
    end

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
