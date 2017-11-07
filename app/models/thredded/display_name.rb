# frozen_string_literal: true

module Thredded
    class DisplayName < ActiveRecord::Base
        self.table_name = 'display_names'
        self.primary_key = :index_user_display_on_user_id_topic_id
        
        belongs_to :user,
           class_name: Thredded.user_class_name
        belongs_to :postable,
               class_name:    'Thredded::Topic'
               
        
        def self.create_unless_exists(user_id, topic_id, reason = :manual)
          new_display_name = Haikunator.haikunate(0, '-').capitalize!
          uncached do
            transaction(requires_new: true) do
              create_with(reason: reason).find_or_create_by(user_id: user_id, topic_id: topic_id, display_name: new_display_name)
            end
          end
        rescue ActiveRecord::RecordNotUnique
          # The record has been created from another connection, retry to find it.
          retry
        end
    end
end