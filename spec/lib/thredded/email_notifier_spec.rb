# frozen_string_literal: true
require 'spec_helper'

describe Thredded::EmailNotifier do
  describe 'new_post' do
    let(:post) { create :post }
    let(:user) { create :user }
    subject { Thredded::EmailNotifier.new.new_post(post, [user]) }
    it "sends an email to targetted users" do
      expect { subject }.to change { ActionMailer::Base.deliveries.count }.by(1)
    end
    it "records notifications" do
      expect { subject }.to change { Thredded::PostNotification.count }.by(1)
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
