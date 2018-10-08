# frozen_string_literal: true

module Thredded
  class ThemePreviewsController < Thredded::ApplicationController
    def show # rubocop:disable Metrics/MethodLength
      @messageboard = Thredded::Messageboard.first
      fail Thredded::Errors::DatabaseEmpty unless @messageboard
      @user = if thredded_current_user.thredded_anonymous?
                Thredded.user_class.new(id: 1334, name: 'joe', email: 'joe@example.com')
              else
                thredded_current_user
              end
      @messageboard_views = [
        Thredded::MessageboardView.new(@messageboard, unread_topics_count: 3, unread_followed_topics_count: 2),
        Thredded::MessageboardView.new(Thredded::Messageboard.first(2)[-1], unread_topics_count: 2),
        Thredded::MessageboardView.new(Thredded::Messageboard.first(3)[-1]),
      ]
      @topics = Thredded::TopicsPageView.new(@user, @messageboard.topics
                                            .send(Kaminari.config.page_method_name, 1)
                                            .limit(3))
      @private_topics = Thredded::PrivateTopicsPageView.new(@user, @user.thredded_private_topics.page(1).limit(3))
      topic = Thredded::Topic.new(messageboard: @messageboard, title: 'Hello', slug: 'hello', user: @user)
      @topic = Thredded::TopicView.from_user(topic, @user)
      @posts = Thredded::TopicPostsPageView.new(@user, topic, topic.posts
                                                .send(Kaminari.config.page_method_name, 1)
                                                .limit(3))
      @post = topic.posts.build(id: 1337, postable: topic, content: 'Hello world', user: @user)
      @post_form = Thredded::PostForm.for_persisted(@post)
      @new_post = Thredded::PostForm.new(user: @user, topic: topic)
      @new_topic = Thredded::TopicForm.new(user: @user, messageboard: @messageboard)
      @new_private_topic = Thredded::PrivateTopicForm.new(user: @user)
      private_topic = Thredded::PrivateTopic.new(id: 17, title: 'Hello', user: @user, last_user: @user, users: [@user])
      @private_topic = Thredded::PrivateTopicView.from_user(private_topic, @user)
      @private_posts = Thredded::TopicPostsPageView.new(@user, private_topic, private_topic.posts
                                                        .send(Kaminari.config.page_method_name, 1)
                                                        .limit(3))
      @private_post = private_topic.posts.build(
        id: 1337, postable: private_topic, content: 'A private hello world', user: @user
      )
      @private_post_form = Thredded::PrivatePostForm.for_persisted(@private_post)
      @preferences = Thredded::UserPreferencesForm.new(user: @user, messageboard: @messageboard)
    end
  end
end
