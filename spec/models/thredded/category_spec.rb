# frozen_string_literal: true
require 'spec_helper'

module Thredded
  describe Category do
    it 'should allow no categories' do
      topic = create(:topic)
      topic.category_ids = nil
      topic.save

      expect(topic).to be_valid
    end

    it 'should allow a category' do
      topic = create(:topic)
      topic.categories << create(:category, messageboard: topic.messageboard)
      topic.save

      expect(topic.categories).not_to be_nil
    end
  end
end
