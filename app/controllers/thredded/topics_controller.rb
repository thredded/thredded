module Thredded
  class TopicsController < Thredded::ApplicationController
    helper_method :current_page
    before_filter :update_user_activity

    def index
      if cannot? :read, messageboard
        error = 'You are not authorized access to this messageboard.'
        redirect_to default_home, flash: { error: error }
      end

      @topics = topics
    end

    def search
      @topics = search_results

      if @topics.empty?
        error = 'No topics found for this search.'
        redirect_to messageboard_topics_path(messageboard),
          flash: { error: error }
      end
    end

    def new
      @topic = messageboard.topics.build
      @topic
        .posts
        .build

      unless can? :create, @topic
        error = 'Sorry, you are not authorized to post on this messageboard.'
        redirect_to messageboard_topics_url(messageboard),
          flash: { error: error }
      end
    end

    def by_category
      @topics = topics_by_category(params[:category_id])
      @category_name = Category.find(params[:category_id]).name
    end

    def create
      @topic = messageboard.topics.create(topic_and_post_params)
      redirect_to messageboard_topics_path(messageboard)
    end

    def edit
      authorize! :update, topic
    end

    def update
      topic.update_attributes(topic_params)
      redirect_to messageboard_topic_posts_url(messageboard, topic)
    end

    private

    def topic
      if messageboard
        @topic ||= messageboard.topics.friendly.find(params[:id])
      end
    end

    def topic_params
      params
        .require(:topic)
        .permit!
        .deep_merge!({
          user: current_user,
          last_user: current_user
        })
    end

    def topic_and_post_params
      params
        .require(:topic)
        .permit!
        .deep_merge!({
          last_user: current_user,
          user: current_user,
          posts_attributes: {
            '0' => {
              messageboard: messageboard,
              ip: request.remote_ip,
              user: current_user,
              filter: messageboard.filter,
            }
          }
        })
    end

    def search_results
      Topic.full_text_search(params[:q], messageboard)
    end

    def topics_by_category(category_id)
      topics = Category.find(category_id)
        .topics
        .unstuck
        .public
        .for_messageboard(messageboard)
        .order_by_updated
        .on_page(current_page)
    end

    def topics
      Topic
        .public
        .for_messageboard(messageboard)
        .includes(:user_topic_reads)
        .order_by_stuck_and_updated_time
        .on_page(current_page)
    end

    def current_page
      params[:page] || 1
    end
  end
end
