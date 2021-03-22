# frozen_string_literal: true

class BadgeSerializer
  include JSONAPI::Serializer
  attributes :title, :description, :secret, :created_at, :updated_at

  attribute :badge_icon do |badge|
    Rails.application.routes.url_helpers.rails_blob_url(badge.badge_icon, only_path: true) if badge.badge_icon.attached?
  end

  has_many :users
end
