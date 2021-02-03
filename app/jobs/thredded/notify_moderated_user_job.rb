# frozen_string_literal: true

module Thredded
  class NotifyModeratedUserJob < ::ActiveJob::Base
    queue_as :default

    def perform(user_detail_id)
      user_detail = Thredded::UserDetail.find(user_detail_id)
      Thredded::NotifyModeratedUser.new(user_detail).run
    end
  end
end
