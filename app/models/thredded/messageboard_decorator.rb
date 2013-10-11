module Thredded
  class MessageboardDecorator < SimpleDelegator
    attr_reader :messageboard

    def initialize(messageboard)
      super
      @messageboard = messageboard
    end

    def category_options
      messageboard.categories.map { |cat| [cat.name, cat.id] }
    end

    def users_options
      messageboard.users.map { |user| [user.to_s, user.id] }
    end
  end
end
