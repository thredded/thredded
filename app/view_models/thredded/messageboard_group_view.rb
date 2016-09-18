# frozen_string_literal: true
module Thredded
  # A view model for a page of MessageboardGroupViews.
  class MessageboardGroupView
    delegate :name, to: :@group, allow_nil: true
    attr_reader :group, :messageboards
    # @param group Thredded::MessageboardGroup
    # @param messageboards [Thredded::TopicCommon]
    def initialize(group, messageboards)
      @group = group
      @messageboards = messageboards.sort_by{|m| - m.updated_at.to_f }
    end
  end
end
