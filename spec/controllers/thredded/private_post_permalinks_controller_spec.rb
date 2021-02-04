# frozen_string_literal: true

require 'spec_helper'

module Thredded
  describe PrivatePostPermalinksController do
    routes { Thredded::Engine.routes }

    let(:user) { create(:user) }

    before { allow(controller).to receive_messages(thredded_current_user: user) }

    it 'returns status code 200 if the user can read the private post' do
      get :show, params: { id: create(:private_post, user: user).id }
      expect(response).to have_http_status(:ok)
    end

    it 'returns status code 403 if the user cannot read the private post' do
      get :show, params: { id: create(:private_post).id }
      expect(response).to have_http_status(:forbidden)
    end
  end
end
