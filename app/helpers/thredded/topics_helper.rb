module Thredded
  module TopicsHelper
    require 'digest/md5'

    def md5(s)
      Digest::MD5.hexdigest(s)
    end

    def already_read(topic, tracked_user_reads)
      if tracked_user_reads
        topic_status = tracked_user_reads.select{ |t| t.topic_id == topic.id }.first

        if topic_status && topic_status.posts_count == topic.posts_count
          'read'
        else
          'unread'
        end
      end
    end
  end
end
