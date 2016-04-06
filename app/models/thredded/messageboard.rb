module Thredded
  class Messageboard < ActiveRecord::Base
    FILTERS = %w(markdown bbcode)

    extend FriendlyId
    friendly_id :slug_candidates,
                use:            [:slugged, :reserved],
                # Avoid route conflicts
                reserved_words: %w(messageboards private-topics autocomplete-users theme-preview)

    validates :filter, inclusion: { in: FILTERS }, presence: true
    validates :name, uniqueness: true, length: { maximum: 60 }, presence: true
    validates :topics_count, numericality: true

    has_many :categories, dependent: :destroy
    has_many :notification_preferences, dependent: :destroy
    has_many :posts, dependent: :destroy
    has_many :topics, dependent: :destroy
    has_many :user_details, through: :posts

    has_many :messageboard_users,
             class_name:  'Thredded::MessageboardUser',
             inverse_of:  :messageboard,
             foreign_key: :thredded_messageboard_id
    has_many :recently_active_user_details,
             -> { merge(Thredded::MessageboardUser.recently_active) },
             class_name: 'Thredded::UserDetail',
             through:    :messageboard_users,
             source:     :user_detail
    has_many :recently_active_users,
             class_name: Thredded.user_class,
             through:    :recently_active_user_details,
             source:     :user

    default_scope { where(closed: false).order(topics_count: :desc) }

    def self.decorate
      all.map do |messageboard|
        MessageboardDecorator.new(messageboard)
      end
    end

    def preferences_for(user)
      @preferences_for ||=
        notification_preferences.where(user_id: user).first_or_create
    end

    def decorate
      MessageboardDecorator.new(self)
    end

    def slug_candidates
      [
        :name,
        [:name, '-board']
      ]
    end
  end
end
