# frozen_string_literal: true

class EventSerializer
  include JSONAPI::Serializer
  attributes :title, :description, :short_description, :url, :topic_url,:host, :event_date, :end_of_submission_date, :created_at, :updated_at

  belongs_to :user

end
