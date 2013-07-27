module PageObject
  module Authentication
    def logged_in?
      has_css? 'a', text: 'Sign out'
    end

    def signs_out
      visit '/users/sign_out'
    end

    def signs_in_as(name)
      ::User.where(name: name).first_or_create!(email: "#{name}@example.com")
      visit '/sessions/new'
      fill_in 'name', with: name
      click_button 'Sign in'
    end
  end
end

