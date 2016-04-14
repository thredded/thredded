# frozen_string_literal: true
module PageObject
  module Authentication
    def logged_in?
      visit root_path
      has_css? 'a', text: 'Sign out'
    end

    def signs_out
      visit '/users/sign_out'
    end

    def signs_in_as(user)
      PageObject::User.new(user).log_in
    end
  end
end
