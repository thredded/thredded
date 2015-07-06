module Thredded
  class ThemePreviewsController < Thredded::ApplicationController
    before_filter :fail_on_empty_database, if: :no_messageboard?

    def show
      @messageboard = messageboard
      @messageboards = Messageboard.where(closed: false).decorate
      @topics = messageboard.topics.on_page(current_page).limit(3)
      @decorated_topics = TopicDecorator.decorate_all(user, @topics)
      @decorated_private_topics = Thredded::UserPrivateTopicDecorator
        .decorate_all(current_user, user.thredded_private_topics)
      @topic = @topics.find { |t| t.posts.present? } || @topics.first ||
        @messageboard.topics.build(title: 'Hello', slug: 'hello')
      @user_topic = TopicDecorator.new(user, @topic)
      @posts = @topic.posts.first(3)
      @post = @posts.first || @messageboard.posts.build(id: 1337, postable: @topic, content: 'Hello world')
      @new_post = @messageboard.posts.build(postable: @topic)
      @new_topic = TopicForm.new(messageboard: messageboard)
      @new_private_topic = PrivateTopicForm.new(messageboard: messageboard)
      @private_topic = PrivateTopic.all.first || @messageboard.private_topics.build(id: 1337, title: 'Hello')
      @preference = preference
    end

    def messageboard
      @messageboard ||= Messageboard.first
    end

    def preference
      @preference ||= NotificationPreference
        .where(messageboard_id: messageboard.id, user_id: user.id)
        .first_or_create!
    end

    def current_page
      1
    end

    private

    def fail_on_empty_database
      fail Thredded::Errors::DatabaseEmpty
    end

    def no_messageboard?
      !Thredded::Messageboard.any?
    end

    def user
      @user ||= begin
        current_user ||
          ::User.first ||
          ::User.create(name: 'joe', email: 'joe@example.com')
      end
    end
  end
end
