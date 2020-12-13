# frozen_string_literal: true

class PrivateTopicsSerializer
  include FastJsonapi::ObjectSerializer
  attributes :id, :title, :user_names, :content
end