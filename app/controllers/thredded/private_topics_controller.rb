# frozen_string_literal: true
module Thredded
  class PrivateTopicsController < Thredded::ApplicationController
    helper_method :private_topic

    def index
      @private_topics = PrivateTopic
        .distinct
        .for_user(thredded_current_user)
        .order('updated_at DESC')
        .includes(:last_user, :user)
        .on_page(params[:page])
        .load
      @decorated_private_topics = Thredded::UserPrivateTopicDecorator
        .decorate_all(thredded_current_user, @private_topics)

      @new_private_topic = PrivateTopicForm.new(user: thredded_current_user)
    end

    def show
      authorize! :read, private_topic
      UserReadsPrivateTopic.new(private_topic, thredded_current_user).run

      @posts = private_topic
        .posts
        .includes(:user)
        .order_oldest_first

      @post = private_topic.posts.build
    end

    def new
      @private_topic = PrivateTopicForm.new(user: thredded_current_user)
      authorize_creating @private_topic.private_topic
    end

    def create
      @private_topic = PrivateTopicForm.new(new_private_topic_params)
      if @private_topic.save
        NotifyPrivateTopicUsersJob
          .perform_later(@private_topic.private_topic.id)

        UserResetsPrivateTopicToUnread
          .new(@private_topic.private_topic, thredded_current_user)
          .run

        redirect_to @private_topic.private_topic
      else
        render :new
      end
    end

    private

    def private_topic
      @private_topic ||= Thredded::PrivateTopic.find_by_slug(params[:id])
    end

    def new_private_topic_params
      params
        .require(:private_topic)
        .permit(:title, :locked, :sticky, :content, :user_ids, user_ids: [], category_ids: [])
        .merge(
          user: thredded_current_user,
          ip:   request.remote_ip
        ).tap do |p|
        # select2 returns a string of IDs joined with commas. Adapt:
        p[:user_ids] = p[:user_ids].split(',') if p[:user_ids].is_a?(String)
      end
    end
  end
end
