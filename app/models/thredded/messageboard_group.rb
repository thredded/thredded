# frozen_string_literal: true

module Thredded
  class MessageboardGroup < ActiveRecord::Base
    has_many :messageboards,
             inverse_of: :group,
             foreign_key: :messageboard_group_id,
             dependent: :nullify

    scope :ordered, -> { order(position: :asc, id: :asc) }
    validates :name,
              presence: true,
              uniqueness: { case_sensitive: false }
    validates :position, presence: true, on: :update
    before_save :ensure_position

    def ensure_position
      self.position ||= Time.zone.now.to_i
    end
  end
end
