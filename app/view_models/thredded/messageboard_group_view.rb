# frozen_string_literal: true
module Thredded
  # A view model for a page of MessageboardGroupViews.
  class MessageboardGroupView
    delegate :name, to: :@group, allow_nil: true
    attr_reader :group, :messageboards

    # @param messageboard_scope [ActiveRecord::Relation]
    # @return [Array<MessageboardGroupView>]
    def self.grouped(messageboard_scope)
      messageboard_scope.preload(last_topic: [:last_user])
        .eager_load(:group)
        .order('coalesce(thredded_messageboard_groups.position, 0) asc, thredded_messageboard_groups.id asc').ordered
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
