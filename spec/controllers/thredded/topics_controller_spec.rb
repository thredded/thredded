# frozen_string_literal: true

require 'spec_helper'

module Thredded
  describe TopicsController do
    routes { Thredded::Engine.routes }

    let(:user) { create(:user) }

    before do
      @messageboard = create(:messageboard)
      @topic = create(:topic, messageboard: @messageboard, title: 'hi')
      @post = create(:post, postable: @topic, content: 'hi')
      allow(controller).to receive_messages(
        topics: [@topic],
        cannot?: false,
        the_current_user: user,
        messageboard: @messageboard
      )
    end

    describe 'GET index' do
      it 'renders' do
        get :index, params: { messageboard_id: @messageboard.slug }
        expect(response).to match_schema(TopicViewSchema)
        expect(response).to have_http_status(:ok)
      end

      it 'performs canonical redirect' do
        get :index, params: { messageboard_id: @messageboard.id }
        expect(response).to redirect_to(action: :index, messageboard_id: @messageboard.slug)
      end
    end

    describe 'GET search' do
      it 'renders search' do
        allow(Topic).to receive_messages(search_query: Topic.where(id: @topic.id))
        get :search, params: { messageboard_id: @messageboard.slug, q: 'hi' }

        expect(response).to have_http_status(:ok)
      end

      it 'is successful with spaces around search term(s)' do
        allow(Topic).to receive_messages(search_query: Topic.where(id: @topic.id))
        get :search, params: { messageboard_id: @messageboard.slug, q: '  hi  ' }

        expect(response).to have_http_status(:ok)
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

          expect(JSON.parse(response.body)['data'].size).to eq(0)
        end
      end
    end

    describe 'POST create' do
      let(:topic_params) { { title: 'one', content: 'something' } }

      it 'creates' do
        expect do
          post :create, params: { messageboard_id: @messageboard.slug, topic: topic_params }
        end.to change(Topic, :count).by(1)
      end

      it 'returns status code 201 when created' do
        post :create, params: { messageboard_id: @messageboard.slug, topic: topic_params }
        expect(response).to have_http_status(:created)
      end
    end

    describe 'POST follow' do
      subject(:do_follow) { post :follow, params: { messageboard_id: @messageboard.id, id: @topic.id } }

      it 'follows' do
        expect { do_follow }.to change { @topic.reload.followers.reload.count }.by(1)
      end
      context 'json format' do
        subject(:do_follow) do
          post :follow, params: { messageboard_id: @messageboard.id, id: @topic.id, format: :json }
        end

        it 'returns changed status' do
          do_follow
          expect(response).to have_http_status(:ok)
        end
      end
    end

    describe 'POST unfollow' do
      subject(:do_unfollow) do
        post :unfollow, params: { messageboard_id: @messageboard.id, id: @topic.id }
      end

      before { UserTopicFollow.create_unless_exists(user.id, @topic.id) }

      it 'unfollows' do
        expect { do_unfollow }.to change { @topic.reload.followers.reload.count }.by(-1)
      end

      context 'json format' do
        subject(:do_unfollow) do
          post :unfollow, params: { messageboard_id: @messageboard.id, id: @topic.id, format: :json }
        end

        it 'returns changed status' do
          do_unfollow
          expect(response).to have_http_status(:ok)
        end
      end
    end

    describe 'POST increment' do
      subject(:do_increment) do
        post :increment, params: { messageboard_id: @messageboard.id, id: @topic.id }
      end

      it 'increments' do
        expect { do_increment }.to change { Topic.find(@topic.id).view_count }.by(1)
      end

      it 'returns status code 204 when incremented' do
        do_increment
        expect(response).to have_http_status(:no_content)
      end
    end

    describe 'POST mark_as_read' do
      subject(:mark_as_read) do
        post :mark_as_read, params: { messageboard_id: @messageboard.id, id: @topic.id }
      end

      before do
        @user = create(:user)
        create(:post, postable: @topic, content: 'hi')
        create(:post, postable: @topic, content: 'hi')
        UserTopicReadState.touch!(user.id, @post)
      end

      it 'marks all posts as read' do
        expect { mark_as_read }.to change { Thredded::UserTopicReadState.find_by(user_id: user.id, postable_id: @topic.id).read_posts_count }.by(2)
      end

      it 'returns status code 204 when marked as read' do
        mark_as_read
        expect(response).to have_http_status(:no_content)
      end
    end

    describe 'POST mark_all_as_read' do
      subject(:mark_all_as_read) do
        post :mark_all_as_read
      end

      before do
        @topic_one = create(:topic, with_posts: 2)
        @topic_two = create(:topic, with_posts: 2)
        UserTopicReadState.touch!(user.id, @topic_one.first_post)
        UserTopicReadState.touch!(user.id, @topic_two.first_post)
        # now, 2 out of 4 posts are read
      end

      # rubocop:disable Metrics/LineLength
      it 'marks all posts of all topics as read' do
        expect { mark_all_as_read }.to change { Thredded::UserTopicReadState.find_by(user_id: user.id, postable_id: @topic_one.id).read_posts_count + Thredded::UserTopicReadState.find_by(user_id: user.id, postable_id: @topic_two.id).read_posts_count }.by(2)
      end
      # rubocop:enable Metrics/LineLength

      it 'returns status code 204 when marked as read' do
        mark_all_as_read
        expect(response).to have_http_status(:no_content)
      end
    end
  end
end
