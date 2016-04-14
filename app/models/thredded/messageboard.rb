# frozen_string_literal: true
module Thredded
  class Messageboard < ActiveRecord::Base
    extend FriendlyId
    friendly_id :slug_candidates,
                use:            [:slugged, :reserved],
                # Avoid route conflicts
                reserved_words: ::Thredded::FriendlyIdReservedWordsAndPagination.new(
                  %w(messageboards preferences private-topics autocomplete-users theme-preview)
                )

    validates :name, uniqueness: true, length: { maximum: 60 }, presence: true
    validates :topics_count, numericality: true

    has_many :categories, dependent: :destroy
    has_many :user_messageboard_preferences, dependent: :destroy
    has_many :posts, dependent: :destroy
    has_many :topics, dependent: :destroy, inverse_of: :messageboard
    has_one :latest_topic, -> { order_recently_updated_first },
            class_name: 'Thredded::Topic'

    has_many :user_details, through: :posts
    has_many :messageboard_users,
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

    def decorate
      MessageboardDecorator.new(self)
    end

    def latest_user
      latest_topic.last_user
    end

    def slug_candidates
      [
        :name,
        [:name, '-board']
      ]
    end
  end
end
