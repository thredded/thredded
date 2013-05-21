module Thredded
  class TopicsController < ApplicationController
    before_filter :ensure_messageboard_exists

    def index
      if cannot? :read, messageboard
        error = 'You are not authorized access to this messageboard.'
        redirect_to default_home, flash: { error: error }
      end

      @sticky = get_sticky_topics
      @topics = get_topics
      @tracked_user_reads = UserTopicRead.statuses_for(current_user, @topics)
    end

    def search
      @topics = get_search_results
      @tracked_user_reads = UserTopicRead.statuses_for(current_user, @topics)

      if @topics.empty?
        error = 'No topics found for this search.'
        redirect_to messageboard_topics_path(messageboard), flash: { error: error }
      end
    end

    def new
      @topic = messageboard.topics.build
      @topic.posts.build( filter: current_user.try(:post_filter) )

      unless can? :create, @topic
        error = 'Sorry, you are not authorized to post on this messageboard.'
        redirect_to messageboard_topics_url(messageboard),
          flash: { error: error }
      end
    end

    def by_category
      @sticky = get_sticky_topics
      @topics = get_topics_by_category params[:category_id]
      @category_name = Category.find(params[:category_id]).name
    end

    def create
      merge_default_topics_params
      @topic = Topic.create(params[:topic])
      redirect_to messageboard_topics_url(messageboard)
    end

    def edit
      authorize! :update, topic
    end

    def update
      params.deep_merge!({
        topic: {
          user: current_user,
          last_user: current_user
        }
      })

      topic.update_attributes(params[:topic])
      redirect_to messageboard_topic_posts_url(messageboard, topic)
    end

    private

    def get_search_results
      Topic.full_text_search(params[:q], messageboard)
    end

    def get_topics_by_category(category_id)
      topics = Category.find(category_id)
        .topics
        .unstuck
        .for_messageboard(messageboard)
        .order_by_updated
        .on_page(params[:page])
    end

    def get_topics
      Topic
        .unstuck
        .for_messageboard(messageboard)
        .order_by_updated.on_page(params[:page])
    end

    def get_sticky_topics
      if on_first_topics_page?
        Topic.stuck.for_messageboard(messageboard).order('id DESC')
      else
        []
      end
    end

    def on_first_topics_page?
      params[:page].nil? || params[:page] == '1'
    end
  end
end
