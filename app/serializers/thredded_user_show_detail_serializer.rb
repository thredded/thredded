# frozen_string_literal: true

class ThreddedUserShowDetailSerializer
  include JSONAPI::Serializer
  attributes   :profile_description, :occupation, :location, :camera, :cutting_program, :sound, :lighting, :website_url, :youtube_url, :facebook_url, :twitter_url, :interests, :posts_count, :movies_count, :moderation_state

  attribute :profile_banner do |user_details|
    Rails.application.routes.url_helpers.rails_blob_url(user_details.profile_banner, only_path: true) if user_details.profile_banner.attached?
  end
end