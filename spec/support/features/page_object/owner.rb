require_relative './authentication'

module PageObject
  class Owner
    include Capybara::DSL
    include PageObject::Authentication
    include Rails.application.routes.url_helpers
  end
end
