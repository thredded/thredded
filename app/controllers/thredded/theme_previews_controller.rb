# frozen_string_literal: true
module Thredded
  class ThemePreviewsController < Thredded::ApplicationController
    def show
      @messageboard = Messageboard.first
      fail Thredded::Errors::DatabaseEmpty unless @messageboard

      @user = if thredded_current_user.thredded_anonymous?
                Thredded.user_class.new(
                  id: 1334,
                  name: 'joe',
                  email: 'joe@example.com'
                )
              else
                thredded_current_user
              end
      @messageboards     = Messageboard.all
      @topics            = TopicsPageView.new(@user, @messageboard.topics.page(1).limit(3))
      @private_topics    = PrivateTopicsPageView.new(@user, @user.thredded_private_topics.page(1).limit(3))
      topic              = Topic.new(messageboard: @messageboard, title: 'Hello', slug: 'hello', user: @user)
      @topic             = TopicView.from_user(topic, @user)
      @posts             = TopicPostsPageView.new(@user, topic, topic.posts.page(1).limit(3))
      @post              = topic.posts.build(id: 1337, postable: topic, content: 'Hello world', user: @user)
      @new_post          = @messageboard.posts.build(postable: topic)
      @new_topic         = TopicForm.new(user: @user, messageboard: @messageboard)
      @new_private_topic = PrivateTopicForm.new(user: @user)
      private_topic      = PrivateTopic.new(id: 1337, title: 'Hello', user: @user, last_user: @user, users: [@user])
      @private_topic     = PrivateTopicView.from_user(private_topic, @user)
      @private_posts     = TopicPostsPageView.new(@user, private_topic, private_topic.posts.page(1).limit(3))
      @private_post      = private_topic.posts.build(
        id: 1337,
        postable: private_topic,
        content: 'A private hello world',
        user: @user
      )
      @preferences = UserPreferencesForm.new(user: @user, messageboard: @messageboard)
    end
  end
end
