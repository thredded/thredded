# frozen_string_literal: true

class UserSerializer
  include JSONAPI::Serializer

  attributes  :admin, :name, :email, :created_at, :updated_at

  belongs_to :thredded_main_badge, serializer: BadgeSerializer
end
