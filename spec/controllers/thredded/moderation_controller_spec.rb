# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Thredded::ModerationController do
  routes { Thredded::Engine.routes }

  let(:moderator) { create(:user, admin: true) }

  before { allow(controller).to receive_messages(the_current_user: moderator) }

  it 'GET #pending' do
    create(:topic, with_posts: 1)
    get :pending
    expect(response).to be_successful
    expect(assigns(:posts).to_a.length).to eq(1)
  end
end
