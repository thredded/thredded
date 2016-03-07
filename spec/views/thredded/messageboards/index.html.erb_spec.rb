require 'spec_helper'

RSpec.describe 'thredded/messageboards/index' do
  before do
    # Give view access to route helpers and general helper methods
    view.extend Thredded::Engine.routes.url_helpers
    view.extend Thredded::ApplicationHelper

    # Set up instance variables
    assign(:messageboards, [])

    # Stub the helper methods defined in the controller
    allow(view).to receive_messages(messageboard: nil, active_users: [])

    # Use a generic Ability model so we can grant abilities on the fly
    allow(view).to receive(:current_ability).and_return(Object.new.extend(CanCan::Ability))
  end

  it 'shows the Create button when permitted to create a messageboard' do
    view.current_ability.can(:create, Thredded::Messageboard)

    render

    expect(rendered).to have_link('Create a New Messageboard')
  end

  it 'does not show the Create button when not permitted to create a messageboard' do
    render

    expect(rendered).to_not have_link('Create a New Messageboard')
  end
end
