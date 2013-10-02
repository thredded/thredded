module Thredded
  class TopicsController < ApplicationController
    before_filter :ensure_messageboard_exists
    helper_method :current_page

    def index
      if cannot? :read, messageboard
        error = 'You are not authorized access to this messageboard.'
        redirect_to default_home, flash: { error: error }
      end

      @sticky = sticky_topics
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
      @topic.posts.build( filter: user_messageboard_preferences.try(:filter) )

      unless can? :create, @topic
        error = 'Sorry, you are not authorized to post on this messageboard.'
        redirect_to messageboard_topics_url(messageboard),
          flash: { error: error }
      end
    end

    def by_category
      @sticky = sticky_topics
      @topics = topics_by_category(params[:category_id])
      @category_name = Category.find(params[:category_id]).name
    end

    def create
      @topic = messageboard.topics.create(topic_params)
      redirect_to messageboard_topics_path(messageboard)
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

    def topic
      if messageboard
        @topic ||= messageboard.topics.find(params[:id])
      end
    end

    def topic_params
      params[:topic].deep_merge!({
        last_user: current_user,
        user: current_user,
        posts_attributes: {
          '0' => {
            messageboard: messageboard,
            ip: request.remote_ip,
            user: current_user,
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
        .unstuck
        .public
        .for_messageboard(messageboard)
        .includes(:user_topic_reads)
        .order_by_updated
        .on_page(current_page)
    end

    def sticky_topics
      if current_page == 1
        Topic
          .stuck
          .public
          .for_messageboard(messageboard)
          .order('id DESC')
      else
        []
      end
    end

    def current_page
      params[:page] || 1
    end
  end
end
