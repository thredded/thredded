# frozen_string_literal: true
module Thredded
  class Stats
    include ActionView::Helpers::NumberHelper

    class << self
      def messageboards_count
        new.messageboards_count
      end

      def topics_count
        new.topics_count
      end

      def posts_count
        new.posts_count
      end
    end

    def messageboards_count
      messageboards.count
    end

    def topics_count
      number_to_human(messageboards.map(&:topics_count).sum, precision: 4)
    end

    def posts_count
      number_to_human(messageboards.map(&:posts_count).sum, precision: 5)
    end

    private

    def messageboards
      @messageboards ||= Messageboard.all
    end
  end
end
