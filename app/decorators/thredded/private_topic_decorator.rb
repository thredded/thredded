require 'thredded/base_topic_decorator'

module Thredded
  class PrivateTopicDecorator < SimpleDelegator
    def initialize(private_topic)
      super BaseTopicDecorator.new(private_topic)
    end

    def self.model_name
      ActiveModel::Name.new(self, nil, 'PrivateTopic')
    end

    def to_model
      __getobj__
    end

    def css_class
      classes = []
      classes << 'private_topic'
      classes.join(' ')
    end

    def user_link
      user_path = Thredded.user_path(user)
      "<a href='#{user_path}'>#{user}</a>".html_safe
    end

    def last_user_link
      last_user_path = Thredded.user_path(last_user)
      "<a href='#{last_user_path}'>#{last_user}</a>".html_safe
    end
  end
end
