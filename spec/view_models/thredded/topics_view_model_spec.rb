require 'spec_helper'

module Thredded
  describe TopicsViewModel, '#to_partial_path' do
    it 'returns the topic path' do
      view_model = Thredded::TopicsViewModel.new(messageboard_id: 'board')

      expect(view_model.to_partial_path).to eq 'thredded/topics/topic'
    end
  end

  describe TopicsViewModel, 'messageboard' do
    it 'returns the messageboard based on contents of params' do
      messageboard = create(:messageboard, slug: 'board')
      view_model = Thredded::TopicsViewModel.new(messageboard_id: 'board')

      expect(view_model.messageboard).to eq messageboard
    end
  end

  describe TopicsViewModel, '#new_topic' do
    it 'returns a new TopicForm' do
      create(:messageboard, slug: 'board')
      view_model = Thredded::TopicsViewModel.new(messageboard_id: 'board')

      expect(view_model.new_topic).to be_a(Thredded::TopicForm)
    end
  end

  describe TopicsViewModel, '#topics' do
    it 'returns all un-decorated topics for the messageboard' do
      messageboard = create(:messageboard, slug: 'board')
      oldest_topic = create(:topic, messageboard: messageboard)
      newest_topic = create(:topic, messageboard: messageboard)
      view_model = Thredded::TopicsViewModel.new(messageboard_id: 'board')

      expect(view_model.topics.first).to eq newest_topic
      expect(view_model.topics.last).to eq oldest_topic
    end
  end

  describe TopicsViewModel, '#each' do
    it 'delegates to the topics array' do
      messageboard = create(:messageboard, slug: 'board')
      create(:topic, messageboard: messageboard, title: '1')
      create(:topic, messageboard: messageboard, title: '2')
      view_model = Thredded::TopicsViewModel.new(messageboard_id: 'board')
      titles = []

      view_model.each do |topic|
        titles << topic.title
      end

      expect(titles).to eq ['2', '1']
    end
  end

  describe TopicsViewModel, '#map' do
    it 'delegates to the topics array' do
      messageboard = create(:messageboard, slug: 'board')
      create(:topic, messageboard: messageboard, title: '1')
      create(:topic, messageboard: messageboard, title: '2')
      view_model = Thredded::TopicsViewModel.new(messageboard_id: 'board')

      titles = view_model.map do |topic|
        topic.title
      end

      expect(titles).to eq ['2', '1']
    end
  end
end
