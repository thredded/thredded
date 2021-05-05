# frozen_string_literal: true

module Thredded
  class MovieLikesUserUpdaterJob < ::ActiveJob::Base
    queue_as :default

    def perform(user_id)

      begin
        movies = Topic.where(user_id: user_id).get_movies
        counter = 0
        movies.each do |movie|
          counter += movie.likes_count
        end

        user_detail = Thredded::UserDetail.find_or_initialize_by(user_id: user_id)
        user_detail.update!(received_likes_movies: counter)
      end
    end
  end
end
