require_relative './authentication'

module PageObject
  class Owner
    include Capybara::DSL
    include Authentication
    include FactoryGirl::Syntax::Methods
    include Rails.application.routes.url_helpers

    def signs_in_as(name)
      user = ::User
        .where(name: name)
        .first_or_create!(email: "#{name}@example.com")
      create(:user_detail, user: user, superadmin: true)

      visit '/sessions/new'
      fill_in 'name', with: name
      click_button 'Sign in'
    end
  end
end
