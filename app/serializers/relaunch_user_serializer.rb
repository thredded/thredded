# frozen_string_literal: true

class RelaunchUserSerializer
  include JSONAPI::Serializer
  attributes :email, :username, :hash, :created_at

end
