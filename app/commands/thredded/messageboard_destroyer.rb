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

      connection.execute <<-SQL
        DELETE FROM thredded_images
          USING thredded_posts p
          WHERE post_id = p.id
          AND p.messageboard_id = #{messageboard.id}
      SQL

      connection.execute <<-SQL
        DELETE FROM thredded_attachments
          USING thredded_posts p
          WHERE post_id = p.id
          AND p.messageboard_id = #{messageboard.id}
      SQL

      connection.execute <<-SQL
        DELETE FROM thredded_post_notifications
          USING thredded_posts p
          WHERE post_id = p.id
          AND p.messageboard_id = #{messageboard.id}
      SQL

      connection.execute <<-SQL
        DELETE FROM thredded_user_topic_reads
          USING thredded_topics t
          WHERE topic_id = t.id
          AND t.messageboard_id = #{messageboard.id}
      SQL
    end

    def destroy_all_posts
      say 'Destroying all posts ...'

      connection.execute <<-SQL
        DELETE FROM thredded_posts p
          WHERE p.messageboard_id = #{messageboard.id}
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
