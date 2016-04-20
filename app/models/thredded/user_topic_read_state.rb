# frozen_string_literal: true
module Thredded
  class UserTopicReadState < ActiveRecord::Base
    include UserTopicReadStateCommon
    belongs_to :user,
               class_name: Thredded.user_class,
               inverse_of: :thredded_topic_read_states
    belongs_to :postable,
               class_name: 'Thredded::Topic',
               inverse_of: :user_read_states
  end
end
