# frozen_string_literal: true

module Thredded
  class UserBadge < ActiveRecord::Base
    belongs_to :badge, inverse_of: :user_badges
    belongs_to :user, class_name: Thredded.user_class_name, inverse_of: :thredded_user_badges
  end
end
