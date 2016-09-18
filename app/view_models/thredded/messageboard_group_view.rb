# frozen_string_literal: true
module Thredded
  # A view model for a page of MessageboardGroupViews.
  class MessageboardGroupView
    delegate :name, to: :@group, allow_nil: true
    attr_reader :group, :messageboards

    # @param messageboards [ActiveRecord::Relation] A messageboards scope
    # @return [Array<MessageboardGroupView>]
    def self.grouped(messageboards)
      messageboards.preload(last_topic: [:last_user]).includes(:group)
        .order('thredded_messageboard_groups.name asc, thredded_messageboards.updated_at desc')
        .group_by(&:group)
        .map { |(group, messageboards)| MessageboardGroupView.new(group, messageboards) }
    end

    # @param group Thredded::MessageboardGroup
    # @param messageboards [Thredded::TopicCommon]
    def initialize(group, messageboards)
      @group = group
      @messageboards = messageboards
    end
  end
end
