# frozen_string_literal: true
module Thredded
  class MessageboardGroup < ActiveRecord::Base
    has_many :messageboards,
             inverse_of: :group,
             foreign_key: :messageboard_group_id,
             dependent: :nullify

    validates :name, presence: true, uniqueness: true
  end
end
