# frozen_string_literal: true

class PostPermalinkSerializer
  include FastJsonapi::ObjectSerializer
  attributes :messageboards, :group
end