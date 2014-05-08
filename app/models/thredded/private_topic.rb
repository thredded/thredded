module Thredded
  class PrivateTopic < ActiveRecord::Base
    extend FriendlyId
    friendly_id :title, use: :scoped, scope: :messageboard
    paginates_per 50 if self.respond_to?(:paginates_per)

    has_many :posts, -> { includes :attachments }
    has_many :private_users
    has_many :users, through: :private_users

    belongs_to \
      :last_user,
      class_name: Thredded.user_class,
      foreign_key: 'last_user_id'
    belongs_to :user, class_name: Thredded.user_class
    belongs_to :messageboard, counter_cache: true, touch: true

    validates_presence_of :hash_id
    validates_presence_of :last_user_id
    validates_presence_of :messageboard_id
    validates_numericality_of :posts_count
    validates_uniqueness_of :hash_id

    delegate :name, :name=, :email, :email=, to: :user, prefix: true

    def self.on_page(page_num)
      page(page_num).per(30)
    end

    def self.for_messageboard(messageboard)
      where(messageboard_id: messageboard.id)
    end

    def self.decorate
      all.map do |topic|
        TopicDecorator.new(topic)
      end
    end

    def self.find_by_slug(slug)
      includes(:user_topic_reads).friendly.find(slug)
    rescue ActiveRecord::RecordNotFound
      raise Thredded::Errors::TopicNotFound
    end

    def decorate
      TopicDecorator.new(self)
    end

    def last_user
      super || NullUser.new
    end

    def private?
      false
    end

    # * * *

    def self.including_roles_for(user)
      joins(messageboard: :roles)
        .where(thredded_roles: {user_id: user.id})
    end

    def self.for_user(user)
      joins(:private_users)
        .where(thredded_private_users: {user_id: user.id})
    end

    def add_user(user)
      if String == user.class
        user = User.find_by_name(user)
      end

      users << user
    end

    def public?
      false
    end

    def private?
      true
    end

    def user_id=(ids)
      if ids.size > 0
        self.users = User.where(id: ids.uniq)
      end
    end

    def users_to_sentence
      users.map{ |user| user.to_s.capitalize }.to_sentence
    end
  end
end
