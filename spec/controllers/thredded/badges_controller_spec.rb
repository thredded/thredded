# frozen_string_literal: true

require 'spec_helper'

module Thredded
  describe BadgesController do
    routes { Thredded::Engine.routes }

    let(:user) { create(:user) }
    let(:admin) { create(:user, :admin) }

    before do
      @badge_1 = create(:badge, title: 'badge_1')
      @badge_2 = create(:badge, :secret, title: 'badge_2')
      @badge_3 = create(:badge, :secret, title: 'badge_3')
      @badge_3.users |= [user]
    end

    describe 'GET index' do
      it 'returns 1 badge (not secret) if not logged in' do
        get :index
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)['data'].size).to eq(1)
      end

      it 'returns 2 badges (not secret and the own) if logged in as user' do
        allow(controller).to receive_messages(the_current_user: user)
        get :index
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)['data'].size).to eq(2)
      end

      it 'returns 3 badges if logged in as admin' do
        allow(controller).to receive_messages(the_current_user: admin)
        get :index
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)['data'].size).to eq(3)
      end
    end

    describe 'PUT assign' do
      subject(:do_put_request) do
        allow(controller).to receive_messages(the_current_user: admin)
        put :assign, params: { id: @badge_1.id, user_ids: user.id }
      end

      it 'assigns a user' do
        expect(@badge_1.users.count).to eq(0)
        do_put_request
        expect(@badge_1.users.count).to eq(1)
      end
    end

    describe 'DELETE remove' do
      subject(:do_delete_request) do
        allow(controller).to receive_messages(the_current_user: admin)
        delete :remove, params: { id: @badge_3.id, user_ids: user.id }
      end

      it 'removes a user' do
        expect(@badge_3.users.count).to eq(1)
        do_delete_request
        expect(@badge_3.users.count).to eq(0)
      end
    end
  end
end
