# frozen_string_literal: true

module Thredded
  class TopicsController < Thredded::ApplicationController # rubocop:disable Metrics/ClassLength
    include Thredded::NewTopicParams
    include Thredded::NewPostParams

    before_action :thredded_require_login!,
                  only: %i[edit new update create destroy follow unfollow]

    before_action :use_topic_messageboard,
                  only: %i[show edit update destroy follow unfollow]

    after_action :update_user_activity

    after_action :verify_authorized, except: %i[search]
    after_action :verify_policy_scoped, except: %i[show new create edit update destroy follow unfollow]

    def index
      authorize_reading messageboard
      unless params_match?(canonical_messageboard_params)
        skip_policy_scope
        return redirect_to(canonical_messageboard_params)
      end

      page_scope = policy_scope(messageboard.topics)
        .order_sticky_first.order_recently_posted_first
        .page(current_page)
      return redirect_to(last_page_params(page_scope)) if page_beyond_last?(page_scope)
      @topics = Thredded::TopicsPageView.new(thredded_current_user, page_scope)
      Thredded::TopicForm.new(messageboard: messageboard, user: thredded_current_user).tap do |form|
        @new_topic = form if policy(form.topic).create?
      end
    end

    def show
      authorize topic, :read?
      return redirect_to(canonical_topic_params) unless params_match?(canonical_topic_params)
      page_scope = policy_scope(topic.posts)
        .order_oldest_first
        .includes(:user, :messageboard, :postable)
        .page(current_page)
      return redirect_to(last_page_params(page_scope)) if page_beyond_last?(page_scope)
      @posts = Thredded::TopicPostsPageView.new(thredded_current_user, topic, page_scope)

      if thredded_signed_in?
        Thredded::UserTopicReadState.touch!(
          thredded_current_user.id, topic.id, page_scope.last, current_page
        )
      end

      @new_post = Thredded::PostForm.new(user: thredded_current_user, topic: topic, post_params: new_post_params)
    end

    def search
      in_messageboard = params.key?(:messageboard_id)
      if in_messageboard
        authorize_reading messageboard
        unless params_match?(canonical_messageboard_params)
          skip_policy_scope
          return redirect_to(canonical_messageboard_params)
        end
      end
      @query = params[:q].to_s
      topics_scope = policy_scope(
        if in_messageboard
          messageboard.topics
        else
          Thredded::Topic.where(messageboard_id: policy_scope(Thredded::Messageboard.all).pluck(:id))
        end
      )
      page_scope = topics_scope
        .search_query(@query)
        .order_recently_posted_first
        .includes(:categories, :last_user, :user)
        .page(current_page)
      return redirect_to(last_page_params(page_scope)) if page_beyond_last?(page_scope)
      @topics = Thredded::TopicsPageView.new(thredded_current_user, page_scope)
    end

    def new
      @new_topic = Thredded::TopicForm.new(new_topic_params)
      authorize_creating @new_topic.topic
      return redirect_to(canonical_messageboard_params) unless params_match?(canonical_messageboard_params)
      render
    end

    def category
      authorize_reading messageboard
      @category = messageboard.categories.friendly.find(params[:category_id])
      @topics = Thredded::TopicsPageView.new(
        thredded_current_user,
        policy_scope(@category.topics)
          .unstuck
          .order_recently_posted_first
          .page(current_page)
      )
      render :index
    end

    def create
      @new_topic = Thredded::TopicForm.new(new_topic_params)
      authorize_creating @new_topic.topic
      if @new_topic.save
        redirect_to messageboard_topics_path(messageboard)
      else
        render :new
      end
    end

    def edit
      authorize topic, :update?
      return redirect_to(canonical_topic_params) unless params_match?(canonical_topic_params)
      @edit_topic = Thredded::EditTopicForm.new(user: thredded_current_user, topic: topic)
    end

    def update
      topic.assign_attributes(topic_params_for_update)
      authorize topic, :update?
      if topic.messageboard_id_changed?
        # Work around the association not being reset.
        # TODO: report issue to Rails. Looks like a regression of:
        # https://rails.lighthouseapp.com/projects/8994/tickets/2989
        topic.messageboard = Thredded::Messageboard.find(topic.messageboard_id)

        authorize topic.messageboard, :post?
      end
      @edit_topic = Thredded::EditTopicForm.new(user: thredded_current_user, topic: topic)
      if @edit_topic.save
        redirect_to messageboard_topic_url(topic.messageboard, topic),
                    notice: t('thredded.topics.updated_notice')
      else
        render :edit
      end
    end

    def destroy
      authorize topic, :destroy?
      topic.destroy!
      redirect_to messageboard_topics_path(messageboard),
                  notice: t('thredded.topics.deleted_notice')
    end

    def follow
      authorize topic, :read?
      Thredded::UserTopicFollow.create_unless_exists(thredded_current_user.id, topic.id)
      follow_change_response(following: true)
    end

    def unfollow
      authorize topic, :read?
      Thredded::UserTopicFollow.find_by(topic_id: topic.id, user_id: thredded_current_user.id).try(:destroy)
      follow_change_response(following: false)
    end

    private

    def canonical_messageboard_params
      { messageboard_id: messageboard.slug }
    end

    def canonical_topic_params
      { messageboard_id: messageboard.slug, id: topic.slug }
    end

    def follow_change_response(following:)
      notice = following ? t('thredded.topics.followed_notice') : t('thredded.topics.unfollowed_notice')
      respond_to do |format|
        format.html { redirect_to messageboard_topic_url(messageboard, topic), notice: notice }
        format.json { render(json: { follow: following }) }
      end
    end

    # Returns the `@topic` instance variable.
    # If `@topic` is not set, it first sets it to the topic with the slug or ID given by `params[:id]`.
    #
    # @return [Thredded::Topic]
    # @raise [Thredded::Errors::TopicNotFound] if the topic with the given slug does not exist.
    def topic
      @topic ||= Thredded::Topic.friendly_find!(params[:id])
    end

    # Use the topic's messageboard instead of the one specified in the URL,
    # to account for `params[:messageboard_id]` pointing to the wrong messageboard
    def use_topic_messageboard
      @messageboard = topic.messageboard
    end

    def topic_params
      params
        .require(:topic)
        .permit(:title, :locked, :sticky, category_ids: [])
    end

    def topic_params_for_update
      params
        .require(:topic)
        .permit(:title, :locked, :sticky, :messageboard_id, category_ids: [])
    end

    def current_page
      (params[:page] || 1).to_i
    end
  end
end
