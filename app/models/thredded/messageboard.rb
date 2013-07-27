module Thredded
  class Messageboard < ActiveRecord::Base
    SECURITY = %w{private logged_in public}
    PERMISSIONS = %w{members logged_in anonymous}

    extend FriendlyId
    friendly_id :name

    attr_accessible :description,
      :name,
      :posting_permission,
      :security

    default_scope where(closed: false).order('topics_count DESC')

    validates_numericality_of :topics_count
    validates_inclusion_of :security, in: SECURITY
    validates_inclusion_of :posting_permission, in: PERMISSIONS
    validates_presence_of :name
    validates_format_of :name, with: /\A[\w\-]+\z/, on: :create,
      message: 'should be letters, nums, dash, underscore only.'
    validates_uniqueness_of :name,
      message: 'must be a unique board name. Try again.'
    validates_length_of :name, within: 1..16,
      message: 'should be between 1 and 16 characters'

    has_many :categories
    has_many :preferences
    has_many :posts
    has_many :roles
    has_many :topics
    has_many :private_topics
    has_many :users, through: :roles, class_name: Thredded.user_class

    def active_users
      Role
        .joins(:user)
        .where(messageboard_id: self.id)
        .where('last_seen > ?', 5.minutes.ago)
        .order(:last_seen)
        .map(&:user)
    end

    def add_member(user, as='member')
      roles.create(user_id: user.id, level: as)
    end

    def has_member?(user)
      roles.where(user_id: user.id).exists?
    end

    def member_is_a?(user, as)
      roles.where(user_id: user.id, level: as).exists?
    end

    def members_from_list(user_list)
      users.where('lower(name) in (?)', user_list.map(&:downcase))
    end

    def posting_for_anonymous?
      'anonymous' == posting_permission
    end

    def posting_for_logged_in?
      'logged_in' == posting_permission
    end

    def posting_for_members?
      'members' == posting_permission
    end

    def public?
      'public' == security
    end

    def restricted_to_logged_in?
      'logged_in' == security
    end

    def restricted_to_private?
      'private' == security
    end

    def to_param
      name.downcase
    end
  end
end
