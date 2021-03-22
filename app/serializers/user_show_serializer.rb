# frozen_string_literal: true

class UserShowSerializer
  include JSONAPI::Serializer

  attributes :admin, :display_name, :created_at, :updated_at
  attribute :avatar do |user|
    Rails.application.routes.url_helpers.rails_blob_url(user.avatar, only_path: true) if user.avatar.attached?
  end

  has_one :thredded_user_detail, serializer: ThreddedUserShowDetailSerializer
  has_many :thredded_topics, serializer: TopicSerializer
  has_many :thredded_badges, serializer: BadgeSerializer
  belongs_to :thredded_main_badge, serializer: BadgeSerializer
end
