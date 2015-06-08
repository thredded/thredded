module Thredded
  class EnsureRoleExists
    def initialize(params = {})
      @user = params.fetch(:user)
      @messageboard = params.fetch(:messageboard)
    end

    def run
      Thredded::Role.where(
        user: user,
        messageboard: messageboard,
        level: 'member',
      ).first_or_create
    end

    private

    attr_reader :user, :messageboard
  end
end
