# frozen_string_literal: true
require 'spec_helper'

describe Thredded::EmailNotifier do
  describe 'new_post' do
    let(:post) { create :post }
    let(:user) { create :user }
    context 'with the user opting out of email' do
      before { user.thredded_user_preference.followed_topic_emails = false }
      it "doesn't notify" do
        expect {
          Thredded::EmailNotifier.new.new_post(post, [user])
        }.not_to change {
          ActionMailer::Base.deliveries.count
        }
      end

      it 'but TestNotifier would' do
        TestNotifier.resetted
        expect {
          TestNotifier.new.new_post(post, [user])
        }.to change {
          TestNotifier.users_notified_of_new_post
        }
      end
    end
  end

  describe 'new_private_post' do
    let(:post) { create :private_post }
    let(:user) { create :user }
    context 'with a user already notified' do
      before { post.post_notifications.create(email: user.email) }
      it "doesn't notify" do
        expect {
          Thredded::EmailNotifier.new.new_private_post(post, [user])
        }.not_to change {
          ActionMailer::Base.deliveries.count
        }
      end

      it 'but TestNotifier would' do
        TestNotifier.resetted
        expect {
          TestNotifier.new.new_private_post(post, [user])
        }.to change {
          TestNotifier.users_notified_of_new_private_post
        }
      end
    end

    context 'with a user opting out of notifications' do
      # need to implement
    end
  end
end
