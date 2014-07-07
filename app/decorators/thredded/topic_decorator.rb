require 'thredded/base_topic_decorator'

module Thredded
  class TopicDecorator < SimpleDelegator
    def initialize(private_topic)
      super(BaseTopicDecorator.new(private_topic))
    end

    def css_class
      classes = []
      classes << 'locked' if locked?
      classes << 'sticky' if sticky?
      classes += ['category'] + categories.map(&:name) if categories.present?
      classes.join(' ')
    end

    def category_options
      messageboard.decorate.category_options
    end

    def user_link
      if user.anonymous?
        user.to_s
      else
        user_path = Thredded.user_path(user)
        "<a href='#{user_path}'>#{user}</a>".html_safe
      end
    end

    def last_user_link
      if last_user.anonymous?
        last_user.to_s
      else
        last_user_path = Thredded.user_path(last_user)
        "<a href='#{last_user_path}'>#{last_user}</a>".html_safe
      end
    end
  end
end
