require 'spec_helper'
require 'chronic'

module Thredded
  describe BaseTopicDecorator, '#slug' do
    it 'uses the id if slug is nil' do
      topic = build_stubbed(:topic, slug: nil)
      decorated_topic = BaseTopicDecorator.new(topic)

      expect(decorated_topic.slug).to eq topic.id
    end

    it 'uses the slug if it is there' do
      topic = build_stubbed(:topic, slug: 'hi-topic')
      decorated_topic = BaseTopicDecorator.new(topic)

      expect(decorated_topic.slug).to eq 'hi-topic'
    end
  end

  describe BaseTopicDecorator, '#updated_at_timeago' do
    it 'generalizes it if it is nil' do
      topic = build_stubbed(:topic, updated_at: nil, slug: nil)
      decorated_topic = BaseTopicDecorator.new(topic)
      expected_html = <<-eohtml.html_safe.strip_heredoc
        <abbr>
          a little while ago
        </abbr>
      eohtml

      expect(decorated_topic.updated_at_timeago).to eq expected_html
    end

    it 'creates an abbr tag with the right html and content' do
      topic = build_stubbed(:topic, updated_at: Chronic.parse('March 1, 2015 at noon'))
      decorated_topic = BaseTopicDecorator.new(topic)
      expected_html = <<-eohtml.html_safe.strip_heredoc
        <abbr class="timeago" title="2015-03-01T12:00:00Z">
          2015-03-01 12:00:00 UTC
        </abbr>
      eohtml

      expect(decorated_topic.updated_at_timeago).to eq expected_html
    end
  end
end
