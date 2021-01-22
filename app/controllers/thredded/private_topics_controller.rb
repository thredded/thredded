# frozen_string_literal: true

module Thredded
  class PrivateTopicsController < Thredded::ApplicationController
    include Thredded::NewPrivateTopicParams
    include Thredded::NewPrivatePostParams

    before_action :thredded_require_login!

    def index
      page_scope = Thredded::PrivateTopic
        .distinct
        .for_user(thredded_current_user)
        .order_recently_posted_first
        .send(Kaminari.config.page_method_name, params[:page])
      return redirect_to(last_page_params(page_scope)) if page_beyond_last?(page_scope)
      @private_topics = Thredded::PrivateTopicsPageView.new(thredded_current_user, page_scope)

      Thredded::PrivateTopicForm.new(user: thredded_current_user).tap do |form|
        @new_private_topic = form if policy(form.private_topic).create?
      end
      render json: PrivateTopicViewSerializer.new(@private_topics.topic_views).serializable_hash.to_json, status: 200
    end

    def show  
      authorize private_topic, :read?
      page_scope = private_topic
        .posts
        .includes(:user)
        .order_oldest_first
        .send(Kaminari.config.page_method_name, current_page)
      @posts = Thredded::TopicPostsPageView.new(thredded_current_user, private_topic, page_scope)
      render json: TopicPostsPageViewSerializer.new(@posts).serializable_hash.to_json, status: 200
    end

    def new
      @private_topic = Thredded::PrivateTopicForm.new(new_private_topic_params)
      authorize_creating @private_topic.private_topic
    end

    def create
      @private_topic = Thredded::PrivateTopicForm.new(new_private_topic_params)
      if @private_topic.save
        render json: PrivateTopicSerializer.new(@private_topic.private_topic, include: [:user, :users]).serializable_hash.to_json, status: 201
      else
        render json: {errors: @private_topic.errors }, status: 422
      end
    end

    def edit
      authorize private_topic, :update?
      return redirect_to(canonical_topic_params) unless params_match?(canonical_topic_params)
      render
    end

    def destroy
      begin
        @private_topic = Thredded::PrivateTopic.friendly_find!(params[:id])
        authorize @private_topic, :destroy?
        @private_topic.destroy!
      rescue Exception
        raise
      end
      head 204
    end

    def update
      authorize private_topic, :update?
      if private_topic.update(private_topic_params)
        render json: PrivateTopicSerializer.new(private_topic, include: [:user, :users]).serializable_hash.to_json, status: 200
      else
        render json: {errors: private_topic.errors }, status: 422
      end
    end

    private

    def canonical_topic_params
      { id: private_topic.slug }
    end

    def current_page
      (params[:page] || 1).to_i
    end

    # Returns the `@private_topic` instance variable.
    # If `@private_topic` is not set, it first sets it to the topic with the slug or ID given by `params[:id]`.
    #
    # @return [Thredded::PrivateTopic]
    # @raise [Thredded::Errors::PrivateTopicNotFound] if the topic with the given slug does not exist.
    def private_topic
      @private_topic ||= Thredded::PrivateTopic.friendly_find!(params[:id])
    end

    def private_topic_params
      params
        .require(:private_topic)
        .permit(:title)
    end
  end
end
