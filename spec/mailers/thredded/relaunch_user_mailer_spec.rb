# frozen_string_literal: true

require 'spec_helper'

module Thredded
  describe RelaunchUserMailer, 'new_relaunch_user' do
    it 'sets the correct headers' do
      expect(email.from).to eq(['no-reply@example.com'])
      expect(email.to).to eq(['john@email.com'])
      expect(email.subject).to eq([Thredded.email_outgoing_prefix,
                                   'Brickboard 2.0. - Toll, dass du dabei sein möchtest!!'].join)
    end

    it 'renders the body' do
      expect(email.body.encoded).to include('Hallo john!')
    end

    def email
      @email ||= begin
        john = create(:relaunch_user, username: 'john', email: 'john@email.com')
        RelaunchUserMailer.new_relaunch_user(john.email, john.username)
      end
    end
  end
end
