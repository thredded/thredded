# frozen_string_literal: true
module Thredded
  class MembersMarkedNotified
    def initialize(post, members)
      @post = post
      @members = members
    end

    def run
      members.each do |member|
        post.post_notifications.create(email: member.email)
      end
    end

    private

    attr_reader :post, :members
  end
end
