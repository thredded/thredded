# frozen_string_literal: true

class NewsSerializer
  include JSONAPI::Serializer
  attributes :title, :description, :short_description, :url, :topic_url, :created_at, :updated_at
  belongs_to :user

  attribute :news_banner do |banner|
    Rails.application.routes.url_helpers.rails_blob_url(banner.news_banner, only_path: true) if banner.news_banner.attached?
  end
end
