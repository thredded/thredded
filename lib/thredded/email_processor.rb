module Thredded
  class EmailProcessor
    attr_accessor :email, :messageboard, :user

    def initialize(email)
      @email = email
      @user = find_user
      @messageboard = find_messageboard
    end

    def self.process(email)
      processor = self.new(email)
      processor.create_or_update_topic
    end

    def create_or_update_topic
      if can_post_to_topic?
        topic = find_or_build_topic
        post = topic.posts.build(
          user: user,
          content: email.body,
          source: 'email',
          messageboard: messageboard,
        )
        post.user_email = user.email

        topic.save
      else
        return false
      end
    end

    private

    def can_post_to_topic?
      user && messageboard &&
        Thredded::Ability.new(user).can?(:create, messageboard.topics.new)
    end

    def find_or_build_topic
      topic = find_topic

      if topic.nil?
        topic = messageboard.topics.build(title: email.subject)
        topic.user = user
        topic.state = 'pending'
      end

      topic.last_user = user
      topic
    end

    def find_topic
      Thredded::Topic.where(hash_id: email.to).first
    end

    def find_messageboard
      Thredded::Messageboard.where(name: email.to).first || find_topic.try(:messageboard)
    end

    def find_user
      User.where(email: email.from).first
    end
  end
end
