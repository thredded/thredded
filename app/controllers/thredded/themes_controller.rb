require_relative '../../../spec/factories'

module Thredded
  class ThemesController < ApplicationController
    include FactoryGirl::Syntax::Methods

    before_filter :create_messageboard_and_topics, if: :no_messageboard?
    before_filter :theme_view_path

    def show
      @theme = params[:id]
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
      @private_topic = PrivateTopicForm.new(messageboard: messageboard)
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
      @preference ||= MessageboardPreference
        .where(messageboard_id: messageboard.id, user_id: user.id)
        .first_or_create!
    end

    def current_page
      1
    end

    def theme_view_path
      prepend_view_path "themes/#{params[:id]}/views"
    end

    private

    def create_messageboard_and_topics
      board = create(
        :messageboard,
        name: 'Theme Test',
        slug: 'theme-test',
        description: 'A theme is not a theme without some test data'
      )

      topics = create_list(
        :topic, 3,
        messageboard: board,
        user: user,
        last_user: user
      )

      private_topics = create_list(
        :private_topic, 3,
        messageboard: board,
        user: user,
        last_user: user,
        users: [user]
      )

      create(:post, postable: topics[0], messageboard: board, user: user)
      create(:post, postable: topics[1], messageboard: board, user: user)
      create(:post, postable: topics[2], messageboard: board, user: user)

      create(:post, postable: private_topics[0], messageboard: board, user: user)
      create(:post, postable: private_topics[1], messageboard: board, user: user)
      create(:post, postable: private_topics[2], messageboard: board, user: user)
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
