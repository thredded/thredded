# frozen_string_literal: true

require 'spec_helper'

module Thredded
  describe PostPermalinksController do
    routes { Thredded::Engine.routes }

    it 'returns status code 200 if the user can read the post' do
      get :show, params: { id: create(:post).id }
      expect(response).to have_http_status(200)
    end

    it 'returns status code 403 if the user cannot read the post' do
      allow_any_instance_of(PostPolicy).to receive_messages(read?: false) # rubocop:disable RSpec/AnyInstance
      get :show, params: { id: create(:post).id }
      expect(response).to have_http_status(403)
    end
  end
end
