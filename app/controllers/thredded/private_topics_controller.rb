# frozen_string_literal: true
require_dependency 'thredded/posts_page_view'
require_dependency 'thredded/topics_page_view'
module Thredded
  class PrivateTopicsController < Thredded::ApplicationController
    before_action :thredded_require_login!

    def index
      @private_topics = Thredded::PrivateTopicsPageView.new(
        thredded_current_user,
        PrivateTopic
          .distinct
          .for_user(thredded_current_user)
          .order_recently_posted_first
          .includes(:last_user, :user)
          .page(params[:page])
      )

      PrivateTopicForm.new(user: thredded_current_user).tap do |form|
        @new_private_topic = form if policy(form.private_topic).create?
      end
    end

    def show
      authorize private_topic, :read?

      page_scope = private_topic
        .posts
        .includes(:user)
        .order_oldest_first
        .page(current_page)
      @posts = Thredded::TopicPostsPageView.new(thredded_current_user, private_topic, page_scope)

      if signed_in?
        UserPrivateTopicReadState.touch!(thredded_current_user.id, private_topic.id, page_scope.last, current_page)
      end

      @post = private_topic.posts.build
    end

    def new
      @private_topic = PrivateTopicForm.new(user: thredded_current_user)
      authorize_creating @private_topic.private_topic
    end

    def create
      @private_topic = PrivateTopicForm.new(new_private_topic_params)
      if @private_topic.save
        redirect_to @private_topic.private_topic
      else
        render :new
      end
    end

    def edit
      authorize private_topic, :update?
    end

    def update
      authorize private_topic, :update?
      if private_topic.update(private_topic_params)
        redirect_to private_topic_url(private_topic),
                    notice: t('thredded.private_topics.updated_notice')
      else
        render :edit
      end
    end

    private

    def current_page
      (params[:page] || 1).to_i
    end

    def private_topic
      @private_topic ||= Thredded::PrivateTopic.find_by_slug(params[:id])
    end

    def private_topic_params
      params
        .require(:private_topic)
        .permit(:title)
    end

    def new_private_topic_params
      params
        .require(:private_topic)
        .permit(:title, :content, :user_ids, user_ids: [])
        .merge(
          user: thredded_current_user,
          ip:   request.remote_ip
        ).tap { |p| adapt_user_ids! p }
    end

    # select2 returns a string of IDs joined with commas.
    def adapt_user_ids!(p)
      p[:user_ids] = p[:user_ids].split(',') if p[:user_ids].is_a?(String)
    end
  end
end
