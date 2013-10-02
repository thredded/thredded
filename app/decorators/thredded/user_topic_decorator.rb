module Thredded
  class UserTopicDecorator
    extend ActiveModel::Naming
    include ActiveModel::Conversion

    def initialize(user, topic)
      @user = user || NullUser.new
      @topic = topic
    end

    def method_missing(meth, *args)
      if decorated_topic.respond_to?(meth)
        decorated_topic.send(meth, *args)
      else
        super
      end
    end

    def respond_to?(meth)
      decorated_topic.respond_to?(meth)
    end

    def self.decorate_all(user, topics)
      topics.map do |topic|
        new(user, topic)
      end
    end

    def self.model_name
      ActiveModel::Name.new(self, nil, "Topic")
    end

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
        "read #{decorated_topic.css_class}"
      else
        "unread #{decorated_topic.css_class}"
      end
    end

    def user_link
      if user.valid?
        "<a href='/users/#{topic.user_name}'>#{topic.user_name}</a>".html_safe
      else
        '<a href="#">?</a>'.html_safe
      end
    end


    def decorated_topic
      @decorated_topic ||= TopicDecorator.new(topic)
    end

    private

    attr_reader :topic, :user

    def read_status
      if user.valid?
        @read_status ||= topic.user_topic_reads.where(user_id: user.id).first
      end

      @read_status || NullTopicRead.new
    end
  end
end
