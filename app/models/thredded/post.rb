module Thredded
  class Post  < ActiveRecord::Base
    require 'gravtastic'
    include Gravtastic
    include Thredded::Filter::Base
    include Thredded::Filter::Textile
    include Thredded::Filter::Bbcode
    include Thredded::Filter::Markdown
    include Thredded::Filter::Attachment
    include Thredded::Filter::Emoji
    include Thredded::Filter::AtNotification

    gravtastic :user_email
    paginates_per 50

    attr_accessible :attachments_attributes,
      :content,
      :filter,
      :ip,
      :messageboard,
      :source,
      :topic,
      :user

    default_scope order: 'id ASC'

    belongs_to :messageboard, counter_cache: true
    belongs_to :topic, counter_cache: true
    belongs_to :user, class_name: Thredded.user_class
    has_many   :attachments
    has_many   :post_notifications

    accepts_nested_attributes_for :attachments

    validates_presence_of :content, :messageboard_id

    before_validation :set_user_email
    after_create  :modify_parent_topic

    def create
      UserDetail.increment_counter(:posts_count, user_id)
      super
    end

    def created_date
      created_at.strftime("%b %d, %Y %I:%M:%S %Z") if created_at
    end

    def created_timestamp
      created_at.strftime("%Y-%m-%dT%H:%M:%S") if created_at
    end

    def gravatar_url
      super.gsub /http:/, ''
    end

    def self.filters
      ['bbcode', 'markdown']
    end

    private

    def modify_parent_topic
      topic.last_user = user
      topic.touch
      topic.save
    end

    def set_user_email
      if user
        self.user_email = user.email
      end
    end
  end
end
