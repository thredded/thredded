# frozen_string_literal: true

require 'spec_helper'

describe 'View a topic with super-rich content (smoke test)', type: :feature do
  let(:topic) { PageObject::Topic.new(post.postable) }
  let!(:post) { create(:post, content: FakeContent.post_content(with_everything: true)) }
  let(:user) { create(:user) }

  it 'can view a topic with very rich content (smoke test)', js: true do
    topic.visit_topic
  end
end
