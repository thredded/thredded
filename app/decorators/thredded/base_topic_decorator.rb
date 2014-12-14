module Thredded
  class BaseTopicDecorator < SimpleDelegator
    include Thredded::HtmlDecorator

    def slug
      __getobj__.slug.nil? ? id : __getobj__.slug
    end

    def original
      __getobj__
    end

    def updated_at_timeago
      timeago_tag updated_at, class: 'updated_at'
    end

    def created_at_timeago
      timeago_tag created_at, class: 'started_at'
    end

    def user_link
      if user.anonymous?
        user.to_s
      else
        link_to user.to_s, user_path(user)
      end
    end

    def last_user_link
      if last_user.anonymous?
        last_user.to_s
      else
        link_to last_user.to_s, user_path(last_user)
      end
    end
  end
end
