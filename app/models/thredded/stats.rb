# frozen_string_literal: true

module Thredded
  class Stats
    include ActionView::Helpers::NumberHelper

    def messageboards_count
      number_to_human(messageboards.count, precision: 4)
    end

    def topics_count
      number_to_human(messageboards.map(&:topics_count).sum, precision: 4)
    end

    def posts_count
      number_to_human(messageboards.map(&:posts_count).sum, precision: 5)
    end

    private

    def messageboards
      @messageboards ||= Thredded::Messageboard.ordered
    end
  end
end
