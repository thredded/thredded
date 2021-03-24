# frozen_string_literal: true

require 'spec_helper'

module Thredded
  describe ModerationStateMailer, 'moderation_state_notification' do
    it 'sets the correct headers' do
      expect(email.from).to eq(['no-reply@example.com'])
      expect(email.to).to eq(['john@email.com'])
      expect(email.subject).to eq([Thredded.email_outgoing_prefix,
                                   'Willkommen!'].join)
    end

    it 'renders the body' do
      expect(email.body.encoded).to include('Hello john!')
    end

    def email
      @email ||= begin
        john = create(:user, :approved, :with_user_details, name: 'john', email: 'john@email.com')
        ModerationStateMailer.moderation_state_notification("approved", john.thredded_user_detail.id, john.email)
      end
    end
  end
end
