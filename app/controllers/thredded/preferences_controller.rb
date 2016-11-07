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
        params: preferences_params
      )
    end

    def preferences_params
      params.fetch(:user_preferences_form, {}).permit(
        :follow_topics_on_mention,
        :messageboard_follow_topics_on_mention,
        messageboard_notifications_for_followed_topics_attributes: [:wants, :notifier_key, :messageboard_id],
        notifications_for_followed_topics_attributes: [:wants, :notifier_key],
        notifications_for_private_topics_attributes: [:wants, :notifier_key]
      )
    end
  end
end
