# frozen_string_literal: true
require 'spec_helper'

module Thredded
  describe ReadStatesController, type: :controller do
    routes { Thredded::Engine.routes }

    let(:user) { create(:user) }

    subject { put :update }

    before do
      allow(controller).to receive_messages(thredded_current_user: user)
      request.env['HTTP_REFERER'] = root_path
    end

    describe 'PUT update' do
      context 'user is signed in' do
        before do
          allow(controller).to receive(:signed_in?) { true }
        end

        it 'calls MarkAllRead service' do
          expect(MarkAllRead).to receive(:run).with(user)

          subject
        end
      end

      context 'user is not signed in' do
        before do
          allow(controller).to receive(:signed_in?) { false }
        end

        it 'does not call MarkAllRead service' do
          expect(MarkAllRead).not_to receive(:run)

          subject
        end
      end

      it 'redirects to referer' do
        expect(subject).to redirect_to(root_path)
      end
    end
  end
end
