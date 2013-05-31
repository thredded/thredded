module PageObject
  module Authentication
    include FactoryGirl::Syntax::Methods

    def logged_in?
      has_css? 'header nav a', text: 'Logout'
    end

    def signs_out
      visit '/users/sign_out'
    end

    def signs_in_as(name)
      create(:user, name: name, email: "#{name}@example.com")
      visit new_session_path
      fill_in 'name', with: name
      click_button 'Sign in'
    end
  end
end

