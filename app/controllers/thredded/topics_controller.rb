module Thredded
  class TopicsController < Thredded::ApplicationController
    helper_method :current_page, :topic
    before_filter :update_user_activity

    def index
      authorize_reading messageboard

      @topics = topics
    end

    def search
      begin
        @topics = Topic.search(params[:q], messageboard)
      rescue Thredded::Errors::EmptySearchResults
        @topics = []
      end
    end

    def new
      @topic = messageboard.topics.build
      @topic.posts.build

      authorize_creating @topic
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
      @topic ||= messageboard.topics.find_by_slug(params[:id])
    end

    def topics
      Topic
        .public
        .for_messageboard(messageboard)
        .includes(:user_topic_reads, :categories, :messageboard, :last_user, :user)
        .order_by_stuck_and_updated_time
        .on_page(current_page)
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

    def topics_by_category(category_id)
      topics = Category.find(category_id)
        .topics
        .unstuck
        .public
        .for_messageboard(messageboard)
        .order_by_updated
        .on_page(current_page)
    end

    def current_page
      params[:page] || 1
    end
  end
end
