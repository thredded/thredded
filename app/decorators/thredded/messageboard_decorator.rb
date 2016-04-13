module Thredded
  class MessageboardDecorator < SimpleDelegator
    def initialize(messageboard)
      super
      @messageboard = messageboard
    end

    def original
      messageboard
    end

    def category_options
      messageboard.categories.map { |cat| [cat.name, cat.id] }
    end

    private

    attr_reader :messageboard
  end
end
