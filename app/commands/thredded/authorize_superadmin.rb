module Thredded
  class AuthorizeSuperadmin
    def initialize(username)
      @username = username
    end

    def run
      fail Thredded::Errors::UserNotFound if user.blank?

      details = Thredded::UserDetail.where(user: user).first_or_initialize
      details.update_attributes!(superadmin: true)
    end

    protected

    attr_reader :username

    private

    def user
      @user ||= Thredded.user_class.where(Thredded.user_name_column => username).first
    end
  end
end
