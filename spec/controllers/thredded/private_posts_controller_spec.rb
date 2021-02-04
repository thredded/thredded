# frozen_string_literal: true

require 'spec_helper'

module Thredded
  describe PrivatePostsController do
    routes { Thredded::Engine.routes }

    let(:user) { create(:user) }
    let(:private_topic) { create(:private_topic, users: [user, other_user]) }
    let(:private_post) { create(:private_post, postable: private_topic) }
    let(:other_user) { create(:user) }

    before do
      allow(controller).to receive_messages(the_current_user: user)
    end

    describe 'POST mark_as_read' do
      subject(:do_post_request) { post :mark_as_read, params: { id: private_post.id } }

      it 'marks as read' do
        expect(UserPrivateTopicReadState).to receive(:touch!).with(user.id, private_post)
        do_post_request
      end

      context 'json format' do
        subject(:do_post_request) do
          post :mark_as_read, params: { id: private_post.id, format: :json }
        end

        it 'returns changed status' do
          expect(UserPrivateTopicReadState).to receive(:touch!).with(user.id, private_post)
          do_post_request
          expect(response).to have_http_status(:no_content)
        end
      end
    end

    describe 'POST mark_as_unread' do
      subject(:do_post_request) do
        post :mark_as_unread, params: { id: private_post.id }
      end

      it 'marks as unread' do
        UserPrivateTopicReadState.touch!(user.id, private_post)
        expect { do_post_request }.to change(UserPrivateTopicReadState, :count).by(-1)
      end

      context 'json format' do
        subject(:do_post_request) do
          post :mark_as_unread, params: { id: private_post.id, format: :json }
        end

        it 'returns changed status' do
          do_post_request
          expect(response).to have_http_status(:no_content)
        end
      end
    end
  end
end
