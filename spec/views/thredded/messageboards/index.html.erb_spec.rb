# frozen_string_literal: true
require 'spec_helper'

RSpec.describe 'thredded/messageboards/index' do
  before do
    # Give view access to route helpers and general helper methods
    view.extend Thredded::Engine.routes.url_helpers
    view.extend Thredded::ApplicationHelper

    # Set up instance variables
    assign(:messageboards, [])

    # Stub the helper methods defined in the controller
    allow(view).to(
      receive_messages(signed_in?: true, messageboard_or_nil: nil, active_users: [], unread_private_topics_count: 1))

    # Stub the policy, so we can test the view given different permissions
    allow(view).to receive(:policy).and_return(double(Thredded::MessageboardPolicy))
  end

  it 'shows the Create button when permitted to create a messageboard' do
    expect(view.policy).to receive(:create?).and_return(true)

    render

    expect(rendered).to have_link('Create a New Messageboard')
  end

  it 'does not show the Create button when not permitted to create a messageboard' do
    expect(view.policy).to receive(:create?).and_return(false)

    render

    expect(rendered).not_to have_link('Create a New Messageboard')
  end
end
