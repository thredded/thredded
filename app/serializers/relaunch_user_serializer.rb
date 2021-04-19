# frozen_string_literal: true

class RelaunchUserSerializer
  include JSONAPI::Serializer
  attributes :email, :username,:created_at

end
