module Thredded
  class UserTopicDecorator
    extend Forwardable
    extend ActiveModel::Naming
    include ActiveModel::Conversion

    def self.decorate_all(user, topics)
      topics.map do |topic|
        new(user, topic)
      end
    end

    def self.model_name
      ActiveModel::Name.new(self, nil, 'Topic')
    end

    def initialize(user, topic)
      @user = user || NullUser.new
      @topic = TopicDecorator.new(topic)
    end

    def method_missing(meth, *args)
      if topic.respond_to?(meth)
        topic.send(meth, *args)
      else
        super
      end
    end

    def_delegators :topic,
      :created_at_timeago,
      :gravatar_url,
      :last_user_link,
      :original,
      :updated_at_timeago

    def persisted?
      false
    end

    def read?
      topic.posts_count == read_status.posts_count
    end

    def farthest_page
      read_status.page
    end

    def farthest_post
      read_status.farthest_post
    end

    def css_class
      if read?
        "read #{topic.css_class}"
      else
        "unread #{topic.css_class}"
      end
    end

    private

    attr_reader :topic, :user

    def read_status
      if user.id > 0
        @read_status ||= topic.user_topic_reads.select do |reads|
          reads.user_id == user.id
        end
      end

      if @read_status.blank?
        NullTopicRead.new
      else
        @read_status.first
      end
    end
  end
end
