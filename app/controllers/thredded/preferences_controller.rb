# frozen_string_literal: true
module Thredded
  class PreferencesController < Thredded::ApplicationController
    before_action :thredded_require_login!,
                  :init_preferences

    def edit
    end

    def update
      if @preferences.save
        flash[:notice] = t('thredded.preferences.updated_notice')
        redirect_back fallback_location: edit_preferences_url(@preferences.messageboard)
      else
        render :edit
      end
    end

    private

    def init_preferences
      @preferences = UserPreferencesForm.new(
        user:         thredded_current_user,
        messageboard: messageboard_or_nil,
        params:       params.fetch(:user_preferences_form, {}).permit(
          :notify_on_mention,
          :notify_on_message,
          :notify_on_followed_activity,
          :messageboard_notify_on_mention,
          :messageboard_notify_on_followed_activity
        )
      )
    end
  end
end
