# frozen_string_literal: true
module Thredded
  module NotifierPreference
    extend ActiveSupport::Concern

    included do
      delegate :human_name, to: :notifier, prefix: true

      def self.detect_or_default(prefs, notifier)
        (prefs && prefs.find { |pref| pref.notifier_key == notifier.key }) || default(notifier)
      end
    end

    def notifier
      @notifier ||= Thredded.notifiers.find { |notifier| notifier.key == notifier_key }
    end
  end
end
