# frozen_string_literal: true

class MessageboardSerializer
  include JSONAPI::Serializer
  attributes :name, :description, :slug, :topics_count, :movies_count, :posts_count, :position, :locked, :topic_types, :created_at, :updated_at
  attribute :unread_topics_count, if: Proc.new { |messageboard, params|
    params && params[:current_user] && !params[:current_user].thredded_anonymous?
  } do |messageboard, params|
    messageboard.unread_topics_count(params[:current_user])
  end
  belongs_to :messageboard_group
  belongs_to :last_user, serializer: UserSerializer, record_type: :user
  belongs_to :last_topic, serializer: TopicSerializer, record_type: :topic
  belongs_to :badge
end



