require 'spec_helper'
require 'timecop'
require 'chronic'

module Thredded
  describe MessageboardDecorator, '#meta' do
    it 'outputs a humanized count of topics and posts' do
      messageboard = create(
        :messageboard,
        topics_count: 40_343,
        posts_count: 134_500
      )
      decorated_messageboard = MessageboardDecorator.new(messageboard)
      expected_result = '40.3 thousand topics, 135 thousand posts'

      expect(decorated_messageboard.meta).to eq expected_result
    end
  end

  describe MessageboardDecorator, '#latest_topic' do
    it 'returns the most recently updated topic' do
      messageboard = create(:messageboard)
      create_list(:topic, 2, messageboard: messageboard)
      latest = create(:topic, messageboard: messageboard)
      decorated_messageboard = MessageboardDecorator.new(messageboard)

      expect(decorated_messageboard.latest_topic).to eq latest
    end
  end

  describe MessageboardDecorator, '#latest_user' do
    it 'returns the user from the most recently updated topic' do
      me = create(:user)
      them = create(:user)
      messageboard = create(:messageboard)
      create_list(:topic, 2, messageboard: messageboard)
      create(:topic, messageboard: messageboard, last_user: them, user: me)
      decorated_messageboard = MessageboardDecorator.new(messageboard)

      expect(decorated_messageboard.latest_user).to eq them
    end
  end

  describe MessageboardDecorator, '#latest_topic_timeago' do
    it 'spits out an abbr tag with the right markup for timeago' do
      new_years = Chronic.parse('Jan 1 2013 at 3:00pm')

      Timecop.freeze(new_years) do
        messageboard = create(:messageboard)
        create(:topic, messageboard: messageboard, updated_at: new_years)
        decorated_messageboard = MessageboardDecorator.new(messageboard)
        abbr = <<-abbr
          <abbr class="timeago" title="2013-01-01T15:00:00Z">
            2013-01-01 15:00:00 UTC
          </abbr>
        abbr

        expect(decorated_messageboard.latest_topic_timeago).to eq abbr
      end
    end
  end
end
