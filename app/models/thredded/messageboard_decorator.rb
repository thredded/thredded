class MessageboardDecorator < SimpleDelegator
  attr_reader :messageboard

  def initialize(messageboard)
    super
    @messageboard = messageboard
  end

  def category_options
    messageboard.categories.collect { |cat| [cat.name, cat.id] }
  end

  def users_options
    messageboard.users.collect{ |user| [user.name, user.id] }
  end
end
