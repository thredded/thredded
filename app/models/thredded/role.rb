module Thredded
  class Role < ActiveRecord::Base
    ROLES = ['superadmin', 'admin', 'moderator', 'member']

    belongs_to :messageboard
    belongs_to :user

    validates_presence_of   :level
    validates_inclusion_of  :level, in: ROLES
    validates_presence_of   :messageboard_id

    attr_accessible :level, :messageboard_id, :user_id

    scope :for, lambda { |messageboard| where(messageboard_id: messageboard.id) }
    scope :as,  lambda { |role| where(level: role) }
  end
end
