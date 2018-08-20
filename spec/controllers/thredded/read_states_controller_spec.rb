# frozen_string_literal: true

require 'spec_helper'

module Thredded
  describe ReadStatesController, type: :controller do
    routes { Thredded::Engine.routes }

    subject(:do_update) { put :update }

    let(:user) { create(:user) }

    before do
      allow(controller).to receive_messages(thredded_current_user: user)
      request.env['HTTP_REFERER'] = root_path
    end

    describe 'PUT update' do
      context 'user is signed in' do
        before do
          allow(controller).to receive(:thredded_signed_in?).and_return(true)
        end

        it 'calls MarkAllRead service' do
          expect(MarkAllRead).to receive(:run).with(user)

          do_update
        end
      end

      context 'user is not signed in' do
        before do
          allow(controller).to receive(:thredded_signed_in?).and_return(false)
        end

        it 'does not call MarkAllRead service' do
          expect(MarkAllRead).not_to receive(:run)

          do_update
        end
      end

      it 'redirects to referer' do
        expect(do_update).to redirect_to(root_path)
      end
    end
  end
end
