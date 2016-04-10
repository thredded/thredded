module Thredded
  class ThemePreviewsController < Thredded::ApplicationController
    def show
      @messageboard = Messageboard.first
      fail Thredded::Errors::DatabaseEmpty unless @messageboard
      @user                     = if thredded_current_user.thredded_anonymous?
                                    Thredded.user_class.new(id: 1334, name: 'joe', email: 'joe@example.com')
                                  else
                                    thredded_current_user
                                  end
      @messageboards            = Messageboard.where(closed: false).decorate
      @topics                   = messageboard.topics.on_page(1).limit(3)
      @decorated_topics         = UserTopicDecorator.decorate_all(@user, @topics)
      @decorated_private_topics = Thredded::UserPrivateTopicDecorator.decorate_all(@user, @user.thredded_private_topics)
      @topic                    = @topics.find { |t| t.posts.present? } || @topics.first_or_initialize(
        title: 'Hello', slug: 'hello', user: @user)
      @user_topic               = UserTopicDecorator.new(@user, @topic)
      @posts                    = @topic.posts.first(3)
      @post                     = @topic.posts.first_or_initialize(
        id: 1337, postable: @topic, content: 'Hello world', user: @user)
      @new_post                 = @messageboard.posts.build(postable: @topic)
      @new_topic                = TopicForm.new(user: @user, messageboard: @messageboard)
      @new_private_topic        = PrivateTopicForm.new(user: @user)
      @private_topic            = PrivateTopic.first_or_initialize(
        id: 1337, title: 'Hello', user: @user, last_user: @user, users: [@user])
      @private_post             = @private_topic.posts.build(
        id: 1337, postable: @private_topic, content: 'A private hello world', user: @user)
      @preferences              = UserPreferencesForm.new(user: @user, messageboard: @messageboard)
    end
  end
end
