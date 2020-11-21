# frozen_string_literal: true

class ThreddedUserDetailSerializer
  include FastJsonapi::ObjectSerializer
  attributes :moderation_state
end