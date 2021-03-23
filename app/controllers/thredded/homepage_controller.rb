# frozen_string_literal: true

module Thredded
  class HomepageController < Thredded::ApplicationController

    def index
      render json:{random_users: UserShowSerializer.new(random_users, include: %i[thredded_user_detail thredded_main_badge]).serializable_hash,
                   random_movies: TopicSerializer.new(random_movies, include: %i[user categories]).serializable_hash,
                   latest_user: UserSerializer.new(latest_user, include: %i[thredded_user_detail thredded_main_badge]).serializable_hash,
                   latest_topic: TopicSerializer.new(latest_topic, include: %i[messageboard user]).serializable_hash,
                   latest_news: NewsSerializer.new(latest_news),
                   user_count: user_count, topic_count: topic_count, movie_count: movie_count}
                      .to_json, status: 200
    end

    private

    def random_users
      User.all.sample(params[:desired_objects].to_i)
    end

    def random_topics
      Topic.where(type: "Thredded::TopicDefault").sample(params[:desired_objects].to_i)
    end

    def random_movies
      Topic.where(type: "Thredded::TopicMovie").sample(params[:desired_objects].to_i)
    end

    def latest_user
      User.last
    end

    def latest_topic
      Topic.last
    end

    def latest_news
      News.last(params[:desired_objects].to_i)
    end

    def user_count
      User.all.size
    end

    def topic_count
      Topic.where(type: "Thredded::TopicDefault").size
    end

    def movie_count
      Topic.where(type: "Thredded::TopicMovie").size
    end

  end
end
