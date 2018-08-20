# frozen_string_literal: true

require 'spec_helper'

describe Thredded::EmailNotifier do
  let(:user) { create :user }

  it 'is a valid notifier' do
    expect { Thredded::BaseNotifier.validate_notifier(described_class.new) }.not_to raise_error
  end
  describe 'new_post' do
    subject(:notify_new_post) { described_class.new.new_post(post, [user]) }

    let!(:post) { create :post }

    it 'sends an email to targeted users' do
      expect { notify_new_post }.to change { ActionMailer::Base.deliveries.count }.by(1)
    end
  end

  describe 'new_private_post' do
    subject(:notify_new_private_post) { described_class.new.new_private_post(post, [user]) }

    let!(:post) { create :private_post }

    it 'sends an email to targeted users' do
      expect { notify_new_private_post }.to change { ActionMailer::Base.deliveries.count }.by(1)
    end
  end
end
