# frozen_string_literal: true

module Thredded
  class LikePolicy

    def initialize(user, like)
      @user = user
      @like = like
    end

    def destroy?
      @user.thredded_admin? || @like.user_id == @user.id
    end
  end
end
