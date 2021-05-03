# frozen_string_literal: true

module Thredded
  class HomepageController < Thredded::ApplicationController

    def index
      render json: {user_count: user_count, topic_count: topic_count, movie_count: movie_count,
                   random_users: UserShowSerializer.new(random_users, include: %i[thredded_user_detail thredded_main_badge]).serializable_hash,
                   random_movies: TopicSerializer.new(random_movies, include: %i[user categories]).serializable_hash,
                   latest_user: UserShowSerializer.new(latest_user, include: %i[thredded_user_detail thredded_main_badge]).serializable_hash,
                   latest_topic: TopicSerializer.new(latest_topic, include: %i[messageboard user]).serializable_hash,
                   latest_news: NewsSerializer.new(latest_news, include: %i[user user.thredded_user_detail]),
                    current_events: EventSerializer.new(current_events).serializable_hash}
                      .to_json, status: 200
    end

    private

    def get_param
      param = 1
      if params[:desired_objects]
        param = params[:desired_objects].to_i
      end
      param
    end

    def random_users
      User.joins(:thredded_user_detail).where('thredded_user_details.moderation_state': "approved").sample(get_param)
    end

    def random_movies
      Topic.where(type: "Thredded::TopicMovie", moderation_state: "approved").sample(get_param)
    end

    def latest_user
      User.joins(:thredded_user_detail).where('thredded_user_details.moderation_state': "approved").last
    end

    def latest_topic
      Topic.where(moderation_state: "approved").last
    end

    def latest_news
      News.where('is_active = ?', true).order_by_created_date.limit(3)
    end

    def user_count
      User.all.size
    end

    def topic_count
      counter = 0
      Messageboard.all.each do |messageboard|
        counter += messageboard.topics_count
      end
      counter
    end

    def movie_count
      counter = 0
      Messageboard.all.each do |messageboard|
        counter += messageboard.movies_count
      end
      counter
    end

    def current_events
      Event.where('event_date >= ?', DateTime.now).order_by_event_date_asc
    end

  end
end
