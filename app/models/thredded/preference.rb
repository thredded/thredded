module Thredded
  class Preference < ActiveRecord::Base
    attr_accessible :notify_on_mention, :notify_on_message
    belongs_to :user
    belongs_to :messageboard
  end
end
