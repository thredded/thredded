# frozen_string_literal: true
module Thredded
  class PrivateTopicDecorator < SimpleDelegator
    def self.model_name
      ActiveModel::Name.new(self, nil, 'PrivateTopic')
    end

    def to_model
      __getobj__
    end

    def css_class
      'thredded--private-topic'
    end
  end
end
