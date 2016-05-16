# frozen_string_literal: true
require 'spec_helper'

module Thredded
  describe PostPermalinksController do
    routes { Thredded::Engine.routes }

    it 'redirects if the user can read the post' do
      get :show, id: create(:post).id
      expect(response).to be_redirect
    end

    it 'responds with forbidden if the user cannot read the post' do
      allow_any_instance_of(PostPolicy).to receive_messages(read?: false)
      get :show, id: create(:post).id
      expect(response).to be_forbidden
    end
  end
end
