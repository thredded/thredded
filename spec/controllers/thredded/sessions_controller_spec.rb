# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Thredded::SessionsController do
  routes { Thredded::Engine.routes }

  let(:user_approved) { create(:user, :approved) }
  let(:user_blocked) { create(:user, :blocked) }

  describe 'GET logged_in_user' do
    it 'returns 204 for logged in user that is approved' do
      allow(controller).to receive_messages(the_current_user: user_approved)
      get :logged_in_user
      expect(response).to have_http_status(204)
    end

    it 'returns 401 for logged in user that is blocked' do
      allow(controller).to receive_messages(the_current_user: user_blocked)
      get :logged_in_user
      expect(response).to have_http_status(401)
      expect(JSON.parse(response.body)['error']).to eq(Thredded::Errors::SessionBlocked.new.message)
    end

    it 'returns 401 if user is not logged in' do
      get :logged_in_user
      expect(response).to have_http_status(401)
      expect(JSON.parse(response.body)['error']).to eq(Thredded::Errors::SessionNotLoggedIn.new.message)
    end
  end
end
