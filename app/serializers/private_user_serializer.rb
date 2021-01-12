# frozen_string_literal: true

class PrivateUserSerializer
  include JSONAPI::Serializer
  belongs_to :user, serializer: UserSerializer
end