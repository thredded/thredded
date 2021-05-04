# frozen_string_literal: true

require 'spec_helper'

module Thredded
  describe NotificationsController do
    routes { Thredded::Engine.routes }

    let(:user_1) { create(:user) }
    let(:user_2) { create(:user) }

    before do
      @notification_1 = create(:notification, user: user_1)
      @notification_2 = create(:notification, user: user_1)
    end

    describe 'DELETE destroy' do
      it 'can not delete notification if not logged in' do
        delete :destroy, params: { id: @notification_1.id }
        expect(response).to have_http_status(403)
      end

      it 'can not delete notification if it does not belong to user' do
        allow(controller).to receive_messages(the_current_user: user_2)
        delete :destroy, params: { id: @notification_1.id }
        expect(response).to have_http_status(403)
      end

      it 'deletes notification' do
        allow(controller).to receive_messages(the_current_user: user_1)
        delete :destroy, params: { id: @notification_1.id }
        expect(response).to have_http_status(204)
      end
    end

    describe 'DELETE destroy_all' do
      it 'can not delete notifications if not logged in' do
        delete :destroy_all
        expect(response).to have_http_status(403)
      end

      it 'does not delete notifications that dont belong to user' do
        allow(controller).to receive_messages(the_current_user: user_2)
        expect { delete :destroy_all }.to change(Notification, :count).by(0)
      end

      it 'deletes all notifications' do
        allow(controller).to receive_messages(the_current_user: user_1)
        expect { delete :destroy_all }.to change(Notification, :count).by(-2)
      end
    end
  end
end
