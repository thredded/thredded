# frozen_string_literal: true

class PostPreviewSerializer
  include FastJsonapi::ObjectSerializer
  attributes :messageboards, :group
end