# frozen_string_literal: true
module PageObject
  class Base
    include Capybara::DSL
    include FactoryGirl::Syntax::Methods
    include Authentication
    include Thredded::Engine.routes.url_helpers
  end
end
