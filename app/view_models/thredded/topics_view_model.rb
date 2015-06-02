require 'pry'

module Thredded
  class TopicsViewModel < Module
    include Enumerable

    attr_reader :messageboard, :topics

    delegate :total_pages, :limit_value, :each, :map, to: :topics

    def initialize(params)
      @params = params
    end

    def messageboard
      @messageboard ||=
        Thredded::Messageboard.find_by_slug(params[:messageboard_id])
    end

    def cached_messageboard
      Rails.cache.fetch("thredded/#{params[:messageboard_id]}") do
        Thredded::Messageboard.find_by_slug(params[:messageboard_id])
      end
    end

    def new_topic
      @new_topic ||= TopicForm.new(messageboard: messageboard)
    end

    def topics
      @topics ||= messageboard
        .topics
        .includes(:categories, :last_user, :user)
        .order_by_stuck_and_updated_time
        .page(current_page)
        .load
    end

    def decorated
      topics.map { |topic| Thredded::TopicDecorator.new(topic) }
    end

    def to_partial_path
      'thredded/topics/topic'
    end

    def current_page
      params[:page] || 1
    end

    private

    attr_reader :params
  end
end
