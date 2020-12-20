# frozen_string_literal: true

class ThreddedUserDetailSerializer
  include JSONAPI::Serializer
  attributes :moderation_state
end