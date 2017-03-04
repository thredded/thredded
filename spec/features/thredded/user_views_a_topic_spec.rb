# frozen_string_literal: true
require 'spec_helper'

feature 'User views a topic' do
  let(:user) { create(:user) }
  let(:messageboard) { create(:messageboard) }

  context 'when Thredded.show_topic_followers' do
    around do |ex|
      was = Thredded.show_topic_followers
      begin
        Thredded.show_topic_followers = true
        ex.call
      ensure
        Thredded.show_topic_followers = was
      end
    end

    context 'for a followed topic' do
      let(:a_followed_topic) do
        topic = create(:topic, with_posts: 1, messageboard: messageboard)
        Thredded::UserTopicFollow.create_unless_exists(user.id, topic.id)
        PageObject::Topic.new(topic)
      end

      scenario 'can see list of users following topic' do
        a_followed_topic.visit_topic
        within '.thredded--topic-header' do
          expect(page).to have_content(user.name)
        end
      end
    end

    context 'for an unfollowed topic' do
      let(:a_unfollowed_topic) do
        topic = create(:topic, messageboard: messageboard)
        PageObject::Topic.new(topic)
      end

      scenario 'can see that no one is following' do
        a_unfollowed_topic.visit_topic
        within '.thredded--topic-header' do
          expect(page).to have_content('No one is following this topic')
        end
      end
    end
  end

  context 'when not Thredded.show_topic_followers' do
    around do |ex|
      was = Thredded.show_topic_followers
      begin
        Thredded.show_topic_followers = false
        ex.call
      ensure
        Thredded.show_topic_followers = was
      end
    end

    context 'for a followed topic' do
      let(:a_followed_topic) do
        topic = create(:topic, with_posts: 1, messageboard: messageboard)
        Thredded::UserTopicFollow.create_unless_exists(user.id, topic.id)
        PageObject::Topic.new(topic)
      end

      scenario 'can not see list of users following topic' do
        a_followed_topic.visit_topic
        within '.thredded--topic-header' do
          expect(page).to_not have_content(user.name)
        end
      end
    end

    context 'for an unfollowed topic' do
      let(:a_unfollowed_topic) do
        topic = create(:topic, messageboard: messageboard)
        PageObject::Topic.new(topic)
      end

      scenario 'can not see that no one is following' do
        a_unfollowed_topic.visit_topic
        within '.thredded--topic-header' do
          expect(page).to_not have_content('No one is following this topic')
        end
      end
    end
  end

  describe 'view for topic in differing read states' do
    let(:topic) { create(:topic, messageboard: messageboard) }
    let(:topic_page) { PageObject::Topic.new(topic) }
    let(:first_post) { create(:post, postable: topic) }
    let(:second_post) { create(:post, postable: topic) }
    let(:third_post) { create(:post, postable: topic) }
    let(:read_state) { nil }

    before do
      travel_to 2.days.ago do
        first_post
      end
      travel_to 1.day.ago do
        second_post
      end
      travel_to 1.minute.ago do
        third_post
        read_state
      end
    end

    context 'when unlogged in' do
      scenario "posts don't have class of read or unread" do
        topic_page.visit_topic
        expect(page).not_to have_selector('article.thredded--read--post')
        expect(page).not_to have_selector('article.thredded--unread--post')
      end

      scenario "the toggle doen't display" do
        topic_page.visit_topic
        expect(page).to_not have_selector('.thredded--post--dropdown--toggle')
      end
    end

    context 'when logged in' do
      before do
        PageObject::User.new(user).log_in
      end

      context 'when viewing an unread topic' do
        scenario 'the post has a class of unread' do
          topic_page.visit_topic
          expect(page).to have_selector('article.thredded--unread--post', count: 3)
        end
      end

      context 'when viewing a fully read topic' do
        let(:read_state) { create(:user_topic_read_state, postable: topic, user: user, read_at: third_post.created_at) }
        scenario 'each post has a class of read' do
          topic_page.visit_topic
          expect(page).to have_selector('article.thredded--read--post', count: 3)
        end
      end

      context 'when viewing a part read topic' do
        let(:read_state) do
          create(:user_topic_read_state, postable: topic, user: user, read_at: second_post.created_at)
        end
        scenario 'each post has a class of read' do
          topic_page.visit_topic
          expect(page).to have_selector('article.thredded--read--post', count: 2)
          expect(page).to have_selector('article.thredded--unread--post', count: 1)
        end
      end
    end
  end
end
