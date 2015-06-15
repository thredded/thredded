module Thredded
  class Messageboard < ActiveRecord::Base
    SECURITY = %w(private logged_in public)
    PERMISSIONS = %w(members logged_in anonymous)
    FILTERS = %w(markdown bbcode)

    extend FriendlyId
    friendly_id :name, use: :slugged

    validates :filter, inclusion: { in: FILTERS }, presence: true
    validates :name, uniqueness: true, length: { maximum: 60 }, presence: true
    validates :posting_permission, inclusion: { in: PERMISSIONS }
    validates :security, inclusion: { in: SECURITY }
    validates :topics_count, numericality: true

    has_many :categories, dependent: :destroy
    has_many :notification_preferences, dependent: :destroy
    has_many :posts, dependent: :destroy
    has_many :private_topics, dependent: :destroy
    has_many :roles, dependent: :destroy
    has_many :topics, dependent: :destroy
    has_many :users, through: :roles, class_name: Thredded.user_class
    has_many :active_roles, (lambda do
      includes(:user)
        .references(:user)
        .where('last_seen > ?', 5.minutes.ago)
        .order(:last_seen)
    end), class_name: Thredded::Role

    def self.find_by_slug(slug)
      where(slug: slug).first
    end

    def self.default_scope
      where(closed: false).order('topics_count DESC')
    end

    def self.decorate
      all.map do |messageboard|
        MessageboardDecorator.new(messageboard)
      end
    end

    def active_users
      active_roles.map(&:user)
    end

    def preferences_for(user)
      @preferences_for ||=
        notification_preferences.where(user_id: user).first_or_create
    end

    def decorate
      MessageboardDecorator.new(self)
    end

    def add_member(user, as = 'member')
      roles.create(user_id: user.id, level: as)
    end

    def member?(user)
      roles.where(user_id: user.id).exists?
    end

    def member_is_a?(user, as)
      roles.where(user_id: user.id, level: as).exists?
    end

    def members_from_list(user_list)
      CaseInsensitiveStringFinder.new(users, Thredded.user_name_column).find(user_list)
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
  end
end
