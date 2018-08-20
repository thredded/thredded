# frozen_string_literal: true

require 'spec_helper'

module Thredded
  describe PrivatePostPermalinksController do
    routes { Thredded::Engine.routes }

    let(:user) { create(:user) }

    before { allow(controller).to receive_messages(thredded_current_user: user) }

    it 'redirects if the user can read the private post' do
      get :show, params: { id: create(:private_post, user: user).id }
      expect(response).to be_redirect
    end

    it 'responds with forbidden if the user cannot read the private post' do
      get :show, params: { id: create(:private_post).id }
      expect(response).to be_forbidden
    end
  end
end
