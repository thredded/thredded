# frozen_string_literal: true

module Thredded
  class PrivateUser < ActiveRecord::Base
    belongs_to :private_topic, inverse_of: :private_users
    belongs_to :user, class_name: Thredded.user_class_name, inverse_of: :thredded_private_users
  end
end
