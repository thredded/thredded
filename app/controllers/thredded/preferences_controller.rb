# frozen_string_literal: true

module Thredded
  class PreferencesController < Thredded::ApplicationController
    before_action :thredded_require_login!,
                  :init_preferences, only: %i[update]

    def update
      if @preferences.save
        render json: UserPreferencesSerializer.new(@preferences.user_preferences, include: [:messageboard_preferences]).serializable_hash.to_json, status: 201
      else
        render json: { errors: @preferences.errors }, status: 422
      end
    end

    def show
      user_preferences = thredded_current_user.thredded_user_preference
      render json: UserPreferencesSerializer.new(user_preferences, include: [:messageboard_preferences]).serializable_hash.to_json, status: 201
    end

    private

    def init_preferences
      @preferences = Thredded::UserPreferencesForm.new(
        user:         thredded_current_user,
        messageboard: messageboard_or_nil,
        messageboards: policy_scope(Thredded::Messageboard.all),
        params: preferences_params
      )
    end

    def preferences_params
      params.fetch(:user_preferences_form, {}).permit(
        :auto_follow_topics,
        :messageboard_auto_follow_topics,
        :follow_topics_on_mention,
        :messageboard_follow_topics_on_mention,
        messageboard_notifications_for_followed_topics_attributes: %i[notifier_key id messageboard_id enabled],
        notifications_for_followed_topics_attributes: %i[notifier_key id enabled],
        notifications_for_private_topics_attributes: %i[notifier_key id enabled]
      )
    end
  end
end
