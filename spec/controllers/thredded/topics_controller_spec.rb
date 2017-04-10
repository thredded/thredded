# frozen_string_literal: true
require 'spec_helper'

module Thredded
  describe TopicsController do
    routes { Thredded::Engine.routes }

    let(:user) { create(:user) }
    before do
      @messageboard = create(:messageboard)
      @topic        = create(:topic, messageboard: @messageboard, title: 'hi')
      @post         = create(:post, postable: @topic, content: 'hi')
      allow(controller).to receive_messages(
        topics:        [@topic],
        cannot?:       false,
        the_current_user:  user
      )
    end

    describe 'GET index' do
      it 'renders' do
        get :index, params: { messageboard_id: @messageboard.slug }

        expect(response).to be_successful
        expect(response).to render_template('index')
      end

      it 'performs canonical redirect' do
        get :index, params: { messageboard_id: @messageboard.id }
        expect(response).to redirect_to(action: :index, messageboard_id: @messageboard.slug)
      end

      context 'with missing messageboard' do
        it 'returns a 404 for HTML requests' do
          get :index, params: { messageboard_id: 'notfound' }
          expect(response.status).to eq(404)
        end

        it 'returns a 404 for JSON requests' do
          get :index, params: { messageboard_id: 'notfound', format: :json }
          expect(response.status).to eq(404)
        end
      end
    end

    describe 'GET search' do
      it 'renders search' do
        allow(Topic).to receive_messages(search_query: Topic.where(id: @topic.id))
        get :search, params: { messageboard_id: @messageboard.slug, q: 'hi' }

        expect(response).to be_successful
        expect(response).to render_template('search')
      end

      it 'is successful with spaces around search term(s)' do
        allow(Topic).to receive_messages(search_query: Topic.where(id: @topic.id))
        get :search, params: { messageboard_id: @messageboard.slug, q: '  hi  ' }

        expect(response).to be_successful
      end

      it 'performs canonical redirect' do
        get :search, params: { messageboard_id: @messageboard.id }
        expect(response).to redirect_to(action: :search, messageboard_id: @messageboard.slug)
      end

      context 'renders' do
        render_views
        it 'a No Results message' do
          allow(Topic).to receive_messages(search_query: Topic.none)
          get :search, params: { messageboard_id: @messageboard.slug, q: 'hi' }

          expect(response.body).to have_content "There are no results for your search - 'hi'"
        end
      end
    end

    describe 'GET new' do
      it 'works with no extra parameters' do
        get :new, params: { messageboard_id: @messageboard.slug }
        expect(response).to be_successful
        expect(response).to render_template('new')
        expect(assigns(:new_topic).title).to be_blank
        expect(assigns(:new_topic).content).to be_blank
      end

      it 'assigns extra parameters' do
        get :new, params: {
          messageboard_id: @messageboard.slug, topic: { title: 'given title', content: 'preset content' }
        }
        expect(response).to be_successful
        expect(response).to render_template('new')
        expect(assigns(:new_topic).title).to eq 'given title'
        expect(assigns(:new_topic).content).to eq 'preset content'
      end

      it 'performs canonical redirect' do
        get :new, params: { messageboard_id: @messageboard.id }
        expect(response).to redirect_to(action: :new, messageboard_id: @messageboard.slug)
      end
    end

    describe 'POST follow' do
      subject { post :follow, params: { messageboard_id: @messageboard.id, id: @topic.id } }
      it 'follows' do
        expect { subject }.to change { @topic.reload.followers.reload.count }.by(1)
      end
      context 'json format' do
        subject { post :follow, params: { messageboard_id: @messageboard.id, id: @topic.id, format: :json } }
        it 'it returns changed status' do
          subject
          expect(JSON.parse(response.body)).to include('follow' => true)
        end
      end
    end

    describe 'POST unfollow' do
      before { UserTopicFollow.create_unless_exists(user.id, @topic.id) }
      subject { post :unfollow, params: { messageboard_id: @messageboard.id, id: @topic.id } }
      it 'unfollows' do
        expect { subject }.to change { @topic.reload.followers.reload.count }.by(-1)
      end
      context 'json format'
      subject { post :unfollow, params: { messageboard_id: @messageboard.id, id: @topic.id, format: :json } }
      it 'it returns changed status' do
        subject
        expect(JSON.parse(response.body)).to include('follow' => false)
      end
    end
  end
end
