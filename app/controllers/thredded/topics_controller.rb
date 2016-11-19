# frozen_string_literal: true
# rubocop:disable Metrics/ClassLength
module Thredded
  class TopicsController < Thredded::ApplicationController
    before_action :thredded_require_login!,
                  only: %i(edit new update create destroy follow unfollow)
    after_action :update_user_activity

    after_action :verify_authorized, except: %i(search)
    after_action :verify_policy_scoped, except: %i(show new create edit update destroy follow unfollow)

    def index
      authorize_reading messageboard

      @topics = Thredded::TopicsPageView.new(
        thredded_current_user,
        policy_scope(messageboard.topics)
          .order_sticky_first.order_recently_posted_first
          .page(current_page)
      )
      Thredded::TopicForm.new(messageboard: messageboard, user: thredded_current_user).tap do |form|
        @new_topic = form if policy(form.topic).create?
      end
    end

    def show
      authorize topic, :read?
      page_scope = policy_scope(topic.posts)
        .order_oldest_first
        .includes(:user, :messageboard, :postable)
        .page(current_page)
      @posts = Thredded::TopicPostsPageView.new(thredded_current_user, topic, page_scope)

      if signed_in?
        Thredded::UserTopicReadState.touch!(
          thredded_current_user.id, topic.id, page_scope.last, current_page
        )
      end

      @new_post = messageboard.posts.build(postable: topic)
    end

    def search
      authorize_reading messageboard if messageboard_or_nil
      @query = params[:q].to_s
      topics_scope = policy_scope(
        if messageboard_or_nil
          messageboard.topics
        else
          Thredded::Topic.where(messageboard_id: policy_scope(Thredded::Messageboard.all).pluck(:id))
        end
      )
      @topics = Thredded::TopicsPageView.new(
        thredded_current_user,
        topics_scope
          .search_query(@query)
          .order_recently_posted_first
          .includes(:categories, :last_user, :user)
          .page(current_page)
      )
    end

    def new
      @new_topic = Thredded::TopicForm.new(new_topic_params)
      authorize_creating @new_topic.topic
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
    end

    def update
      authorize topic, :update?
      if topic.update(topic_params.merge(last_user_id: thredded_current_user.id))
        redirect_to messageboard_topic_url(messageboard, topic),
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

    def follow_change_response(following:)
      notice = following ? t('thredded.topics.followed_notice') : t('thredded.topics.unfollowed_notice')
      respond_to do |format|
        format.html { redirect_to messageboard_topic_url(messageboard, topic), notice: notice }
        format.json { render(json: { follow: following }) }
      end
    end

    def topic
      @topic ||= messageboard.topics.find_by_slug!(params[:id])
    end

    def topic_params
      params
        .require(:topic)
        .permit(:title, :locked, :sticky, category_ids: [])
    end

    def new_topic_params
      params
        .fetch(:topic, {})
        .permit(:title, :locked, :sticky, :content, category_ids: [])
        .merge(
          messageboard: messageboard,
          user: thredded_current_user,
          ip: request.remote_ip,
        )
    end

    def current_page
      (params[:page] || 1).to_i
    end
  end
end
# rubocop:enable Metrics/ClassLength
