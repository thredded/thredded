# frozen_string_literal: true

class CategorySerializer
  include JSONAPI::Serializer
  attributes :name, :description, :locked, :position, :created_at, :updated_at

  attribute :category_icon do |category|
    Rails.application.routes.url_helpers.rails_blob_url(category.category_icon, only_path: true) if category.category_icon.attached?
  end

  has_many :topics
end
