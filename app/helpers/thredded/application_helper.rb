module Thredded
  module ApplicationHelper
    # @param user [Thredded.user_class, Thredded::NullUser]
    # @return [String] path to the user as specified by {Thredded.user_path}
    def user_path(user)
      Thredded.user_path(self, user)
    end

    # @param user [Thredded.user_class, Thredded::NullUser]
    # @return [String] html_safe link to the user
    def user_link(user)
      render partial: 'thredded/users/link', locals: { user: user }
    end

    # @param datetime [DateTime]
    # @return [String] html_safe datetime presentation
    def time_ago(datetime)
      render partial: 'thredded/shared/time_ago', locals: { datetime: datetime }
    end
  end
end
