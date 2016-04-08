module Thredded
  class PreferencesController < Thredded::ApplicationController
    helper_method :preference

    def edit
    end

    def update
      preference.update!(preference_params)
      flash[:notice] = t('thredded.preferences.updated_notice')
      fallback_location = messageboard_topics_url(messageboard)
      if Rails::VERSION::MAJOR >= 5
        redirect_back fallback_location: fallback_location
      else
        redirect_to(:back) rescue ActionController::RedirectBackError redirect_to(fallback_location)
      end
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
