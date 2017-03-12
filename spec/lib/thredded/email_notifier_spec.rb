# frozen_string_literal: true
require 'spec_helper'

describe Thredded::EmailNotifier do
  let(:user) { create :user }
  it 'is a valid notifier' do
    expect { Thredded::BaseNotifier.validate_notifier(Thredded::EmailNotifier.new) }.to_not raise_error
  end
  describe 'new_post' do
    let!(:post) { create :post }
    subject { Thredded::EmailNotifier.new.new_post(post, [user]) }

    it 'sends an email to targeted users' do
      expect { subject }.to change { ActionMailer::Base.deliveries.count }.by(1)
    end
  end

  describe 'new_private_post' do
    let!(:post) { create :private_post }

    subject { Thredded::EmailNotifier.new.new_private_post(post, [user]) }

    it 'sends an email to targeted users' do
      expect { subject }.to change { ActionMailer::Base.deliveries.count }.by(1)
    end
  end
end
