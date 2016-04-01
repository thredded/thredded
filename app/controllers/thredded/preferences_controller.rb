module Thredded
  class PreferencesController < Thredded::ApplicationController
    helper_method :preference

    def edit
    end

    def update
      preference.update_attributes(preference_params)

      redirect_to :back, flash: { notice: 'Your settings have been updated.' }
    end

    def preference
      @preference ||= NotificationPreference
        .where(messageboard_id: messageboard.id, user_id: thredded_current_user.id)
        .first_or_create!
    end

    private

    def preference_params
      params
        .require(:notification_preference)
        .permit(:notify_on_mention, :notify_on_message, :filter)
    end
  end
end
