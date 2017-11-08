# frozen_string_literal: true

module Thredded
    class DisplayName < ActiveRecord::Base
        self.table_name = 'display_names'

        belongs_to :user,
          class_name: Thredded.user_class_name
        belongs_to :postable,
          class_name:    'Thredded::Topic',
          foreign_key: 'topic_id'
        
        validates_uniqueness_of :user_id, scope: :topic_id
        
        def self.create_unless_exists(user_id, topic_id)
          new_display_name = Haikunator.haikunate(0, '-').capitalize!
          uncached do
            transaction(requires_new: true) do
              self.find_or_create_by(user_id: user_id, topic_id: topic_id) do |new|
                new.display_name = new_display_name
              end
            end
          end
        rescue ActiveRecord::RecordNotUnique
          # The record has been created from another connection, retry to find it.
          retry
        end
    end
end