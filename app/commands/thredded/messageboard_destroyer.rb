module Thredded
  class MessageboardDestroyer
    def initialize(messageboard_name)
      @messageboard = Thredded::Messageboard.friendly.find(messageboard_name)
      @connection = ActiveRecord::Base.connection
    rescue
      say "No messageboard with the name '#{messageboard_name}' found."
    end

    def run
      return unless messageboard

      ActiveRecord::Base.transaction do
        destroy_all_lower_dependencies
        destroy_all_posts
        destroy_all_topics
        destroy_messageboard_and_everything_else
      end
    end

    private

    attr_reader :messageboard, :connection

    def destroy_all_lower_dependencies
      say 'Destroying lower level dependencies ...'

      PostNotification
        .joins(:post)
        .merge(Post.where(messageboard_id: messageboard.id))
        .delete_all
    end

    def destroy_all_posts
      say 'Destroying all posts ...'

      connection.execute <<-SQL
        DELETE FROM thredded_posts
          WHERE messageboard_id = #{messageboard.id}
      SQL
    end

    def destroy_all_topics
      say 'Destroying all topics ...'

      connection.execute <<-SQL
        DELETE FROM thredded_topics
          WHERE messageboard_id = #{messageboard.id}
      SQL
    end

    def destroy_messageboard_and_everything_else
      say 'Destroying messageboard and everything else. Sit tight ...'

      @messageboard.destroy!
    end

    def say(message)
      puts message unless Rails.env.test?
    end
  end
end
