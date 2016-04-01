module Thredded
  class ThemePreviewsController < Thredded::ApplicationController
    before_filter :fail_on_empty_database, if: :no_messageboard?

    def show
      @messageboard = messageboard
      @messageboards = Messageboard.where(closed: false).decorate
      @topics = messageboard.topics.on_page(current_page).limit(3)
      @decorated_topics = UserTopicDecorator.decorate_all(user, @topics)
      @decorated_private_topics = Thredded::UserPrivateTopicDecorator
        .decorate_all(thredded_current_user, user.thredded_private_topics)
      @topic = @topics.find { |t| t.posts.present? } || @topics.first ||
        @messageboard.topics.build(title: 'Hello', slug: 'hello', user: user)
      @user_topic = UserTopicDecorator.new(user, @topic)
      @posts = @topic.posts.first(3)
      @post = @posts.first || @messageboard.posts.build(id: 1337, postable: @topic, content: 'Hello world', user: user)
      @new_post = @messageboard.posts.build(postable: @topic)
      @new_topic = TopicForm.new(messageboard: messageboard, user: Thredded::NullUser.new)
      @new_private_topic = PrivateTopicForm.new(user: user)
      @private_topic = PrivateTopic.all.first || PrivateTopic.new(id: 1337, title: 'Hello', user: user, last_user: user,
                                                                  users: [user])
      @private_post = PrivatePost.first ||
        @private_topic.posts.build(id: 1337, postable: @private_topic, content: 'A private hello world', user: user)
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
      @user ||= if thredded_current_user.thredded_anonymous?
                  Thredded.user_class.first_or_create!(slug: 'joe', name: 'joe', email: 'joe@example.com')
                else
                  thredded_current_user
                end
    end
  end
end
