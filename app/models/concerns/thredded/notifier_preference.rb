# frozen_string_literal: true

module Thredded
  module NotifierPreference
    extend ActiveSupport::Concern

    included do
      delegate :human_name, to: :notifier, prefix: true
    end

    def notifier
      @notifier ||= Thredded.notifiers.find { |notifier| notifier.key == notifier_key }
    end
  end
end
