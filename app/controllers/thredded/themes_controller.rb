module Thredded
  class ThemesController < Thredded::ApplicationController
    before_filter :fail_on_empty_database, if: :no_messageboard?

    def show
      @messageboard = messageboard
      @messageboards = Messageboard.where(closed: false).decorate
      @topics = messageboard.topics.on_page(current_page)
      @decorated_topics = UserTopicDecorator.decorate_all(user, @topics)
      @decorated_private_topics = Thredded::UserPrivateTopicDecorator
        .decorate_all(current_user, user.thredded_private_topics)
      @topic = @topics.first
      @user_topic = UserTopicDecorator.new(user, @topic)
      @posts = @topic.posts
      @new_topic = TopicForm.new(messageboard: messageboard)
      @new_private_topic = PrivateTopicForm.new(messageboard: messageboard)
      @private_topic = PrivateTopic.all.first
      @post = Post.new
      @preference = preference
    end

    def active_users
      %w(john gina sam kelly)
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
