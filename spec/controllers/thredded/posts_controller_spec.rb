# frozen_string_literal: true

require 'spec_helper'

module Thredded
  describe PostsController do
    routes { Thredded::Engine.routes }

    let(:user) { create(:user) }
    let(:messageboard) { create(:messageboard) }
    let(:topic) { create(:topic, messageboard: messageboard, title: 'hi') }
    let(:the_post) { create(:post, postable: topic, content: 'hi') }

    before do
      allow(controller).to receive_messages(
        the_current_user: user,
      )
    end

    describe 'POST mark_as_read' do
      subject(:do_post_request) { post :mark_as_read, params: { id: the_post.id } }

      it 'marks as read' do
        expect(UserTopicReadState).to receive(:touch!).with(user.id, the_post)
        do_post_request
      end
      context 'json format' do
        subject(:do_post_request) do
          post :mark_as_read, params: { id: the_post.id, format: :json }
        end

        it 'returns changed status' do
          expect(UserTopicReadState).to receive(:touch!).with(user.id, the_post)
          do_post_request
          expect(JSON.parse(response.body)).to include('read' => true)
        end
      end
    end

    describe 'POST mark_as_unread' do
      subject(:do_post_request) do
        post :mark_as_unread, params: { id: the_post.id }
      end

      it 'marks as unread' do
        UserTopicReadState.touch!(user.id, the_post)
        expect { do_post_request }.to change(UserTopicReadState, :count).by(-1)
      end

      context 'json format' do
        subject(:do_post_request) do
          post :mark_as_unread, params: { id: the_post.id, format: :json }
        end

        it 'returns changed status' do
          do_post_request
          expect(JSON.parse(response.body)).to include('read' => false)
        end
      end
    end
  end
end
