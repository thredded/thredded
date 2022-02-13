# frozen_string_literal: true

require 'spec_helper'

RSpec.feature 'View a topic with super-rich content (smoke test)', type: :feature do
  let(:topic) { PageObject::Topic.new(post.postable) }
  let!(:post) { create(:post, content: FakeContent.post_content(with_everything: true)) }
  let(:user) { create(:user) }

  # This takes a looong time and you may need to increase the timeout for Ferrum (the browser automation under cuprite)
  # You can do this with setting env FERRUM_DEFAULT_TIMEOUT=20 before running this tests, see also .travis.yml:98
  it 'can view a topic with very rich content (smoke test)', js: true do
    topic.visit_topic
  end
end
