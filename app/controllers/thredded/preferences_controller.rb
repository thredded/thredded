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
        params: params.fetch(:user_preferences_form, {}).permit(
          :followed_topic_emails,
          :auto_follow_topics,
          :notify_on_message,
          :messageboard_followed_topic_emails,
          :messageboard_auto_follow_topics
        )
      )
    end
  end
end
